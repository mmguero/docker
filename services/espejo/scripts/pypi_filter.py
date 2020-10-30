#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# TODO: support classifiers (https://pypi.org/classifiers/)

import argparse
import datetime
import json
import os
import re
import requests
import signal
import socket
import sqlite3
import sys
import time
import threading
import zmq

from bs4 import BeautifulSoup as bs
from multiprocessing.pool import ThreadPool
from sqlite3 import Error as SQLError
from multiprocessing import RawValue
from threading import Lock
from pprint import pprint

###################################################################################################
args = None
debug = False
verboseDebug = False
debugToggled = False
pdbFlagged = False
shuttingDown = False
dbWriteLock = Lock()

scriptName = os.path.basename(__file__)
scriptPath = os.path.dirname(os.path.realpath(__file__))
origPath = os.getcwd()

TABLE_NAME="projects"
PROJECT_FIELD="project"
TAGS_FIELD="tag"
CLASSIFIERS_FIELD="classifier"
TIME_FIELD="refreshed"
SQL_CREATE_PROJECTS_STATEMENT = f"CREATE TABLE IF NOT EXISTS {TABLE_NAME} ({PROJECT_FIELD} text NOT NULL, {TAGS_FIELD} text, {CLASSIFIERS_FIELD} text, {TIME_FIELD} timestamp, PRIMARY KEY ({PROJECT_FIELD}));"

###################################################################################################
class AtomicInt:
  def __init__(self, value=0):
    self.val = RawValue('i', value)
    self.lock = Lock()

  def increment(self):
    with self.lock:
      self.val.value += 1
      return self.val.value

  def decrement(self):
    with self.lock:
      self.val.value -= 1
      return self.val.value

  def value(self):
    with self.lock:
      return self.val.value

###################################################################################################
reqWorkersCount = AtomicInt(value=0)
finishedWorkersCount = AtomicInt(value=0)
totalProjCount = AtomicInt(value=0)

###################################################################################################
flatten = lambda *n: (e for a in n
    for e in (flatten(*a) if isinstance(a, (tuple, list)) else (a,)))

###################################################################################################
# handle sigint/sigterm and set a global shutdown variable
def shutdown_handler(signum, frame):
  global shuttingDown
  shuttingDown = True

###################################################################################################
# handle sigusr1 for a pdb breakpoint
def pdb_handler(sig, frame):
  global pdbFlagged
  pdbFlagged = True

###################################################################################################
# handle sigusr2 for toggling debug
def debug_toggle_handler(signum, frame):
  global debug
  global debugToggled
  debug = not debug
  debugToggled = True

###################################################################################################
def find_free_port():
  with socket.socket() as s:
    s.bind(('', 0))            # Bind to a free port provided by the host.
    return s.getsockname()[1]  # Return the port number assigned.

###################################################################################################
# print to stderr
def eprint(*args, **kwargs):
  print(*args, file=sys.stderr, **kwargs)
  sys.stderr.flush()

###################################################################################################
# convenient boolean argument parsing
def str2bool(v):
  if v.lower() in ('yes', 'true', 't', 'y', '1'):
    return True
  elif v.lower() in ('no', 'false', 'f', 'n', '0'):
    return False
  else:
    raise argparse.ArgumentTypeError('Boolean value expected.')

###################################################################################################
# nice human-readable file sizes
def sizeof_fmt(num, suffix='B'):
  for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
    if abs(num) < 1024.0:
      return "%3.1f%s%s" % (num, unit, suffix)
    num /= 1024.0
  return "%.1f%s%s" % (num, 'Yi', suffix)

###################################################################################################
def chunk_list(a, n):
  k, m = divmod(len(a), n)
  return (a[i * k + min(i, m):(i + 1) * k + min(i + 1, m)] for i in range(n))

###################################################################################################
# execute an SQL statement (not query); this one is SQL-injection vulnerable so only use it with create
def execute_statement(conn, statement):
  try:
    cursor = conn.cursor()
    cursor.execute(statement)
  except Exception as e:
    eprint('"{}" raised for "{}"'.format(str(e), statement))

###################################################################################################
# write a record for a project's tags (with "now" for the timestamp)
def update_tags(conn, project, tags, classifiers):
  global dbWriteLock
  with dbWriteLock:
    try:
      cursor = conn.cursor()
      cursor.execute(f"REPLACE INTO {TABLE_NAME} ({PROJECT_FIELD}, {TAGS_FIELD}, {CLASSIFIERS_FIELD}, {TIME_FIELD}) VALUES (?, ?, ?, ?)",
                      (project,
                       json.dumps(tags) if ((tags is not None) and (len(tags) > 0)) else None,
                       json.dumps(classifiers) if ((classifiers is not None) and (len(classifiers) > 0)) else None,
                       datetime.datetime.now(),))
    except Exception as e:
      eprint('"{}" raised for REPLACE "{}"/"{}"/"{}"'.format(str(e), project, tags, classifiers))

###################################################################################################
# check the database first and return the tags for a project. if it's not in there, request it from pypi.
# TODO: have some sort of expiration on the database entries
def get_tags(conn, project, offline):
  try:
    cursor = conn.cursor()
    cursor.execute(f"SELECT {TAGS_FIELD}, {CLASSIFIERS_FIELD} FROM {TABLE_NAME} WHERE ({PROJECT_FIELD} = '{project}')")
    results = cursor.fetchall()
    tags = list()
    classifiers = list()
    if (results is not None) and  (len(results) > 0):
      for row in results:
        if row[0] and (row[0] != 'NULL'):
          tags.extend([x.lower() for x in list(flatten(json.loads(row[0])))])
        if row[1] and (row[1] != 'NULL'):
          classifiers.extend([x.lower() for x in list(flatten(json.loads(row[1])))])
    elif not offline:
      response = requests.get(f'https://pypi.python.org/pypi/{project}/json')
      if response.ok:
        pkgInfo = json.loads(response.text)
        if ('info' in pkgInfo):
          if ('keywords' in pkgInfo['info']) and (pkgInfo['info']['keywords']):
            # this is a pain, because keywords doesn't seem to be consistent:
            #   https://pypi.org/pypi/colored/json has:  color,colour,paint,ansi,terminal,linux,python
            #   https://pypi.org/pypi/colorama/json has: color colour terminal text ansi windows crossplatform xplatform
            #   https://pypi.org/pypi/aam/json has:      Aam,about me,site,static,static page,static site,generator
            # so I guess split on commas if there are any commas, else split on space
            tags.extend([x.strip() for x in pkgInfo['info']['keywords'].split(','  if (',' in pkgInfo['info']['keywords']) else ' ')])
          if ('classifiers' in pkgInfo['info']) and (pkgInfo['info']['classifiers']):
            classifiers.extend([x.strip() for x in pkgInfo['info']['classifiers']])
        update_tags(conn, project, tags, classifiers)
      elif response.status_code == 404:
        update_tags(conn, project, tags, classifiers)

    return tags, classifiers
  except Exception as e:
    eprint('"{}" raised for "{}"'.format(str(e), project))

###################################################################################################
def reqWorker(totalThreadCount, topicPort, allProjects, filterTags, filterClassifiers, sqlConn, offline):
  global debug
  global verboseDebug
  global reqWorkersCount
  global totalProjCount
  global finishedWorkersCount
  global shuttingDown

  reqWorkerId = reqWorkersCount.increment() # unique ID for this thread
  try:

    projectsChunked = list(chunk_list(allProjects, totalThreadCount))
    if (projectsChunked is not None) and (len(projectsChunked) >= reqWorkerId):
      myProjects = projectsChunked[reqWorkerId-1]

      if debug: eprint(f"{scriptName}[{reqWorkerId}]:\t🙂\t{len(myProjects)} projects")

      # tags/classifiers can be string matches (case insensitive) or, if they are prefixed with r:, regex matches (case insensitive)

      tagsStr = [x.lower() for x in filterTags if not x.startswith('r:')]
      tagsRegEx = re.compile('|'.join([x[2:] for x in filterTags if x.startswith('r:')]), re.IGNORECASE) if (len(tagsStr) < len(filterTags)) else re.compile(r'\b\B')

      classifiersStr = [x.lower() for x in filterClassifiers if not x.lower().startswith('r:')]
      classifiersRegEx = re.compile('|'.join([x[2:] for x in filterClassifiers if x.lower().startswith('r:')]), re.IGNORECASE) if (len(classifiersStr) < len(filterClassifiers))  else re.compile(r'\b\B')

      # initialize ZeroMQ context and socket(s) to send scan results
      context = zmq.Context()

      # Socket to send messages to
      matchSocket = context.socket(zmq.PUSH)
      matchSocket.connect(f"tcp://localhost:{topicPort}")

      # todo: do I want to set this? probably not, since what else would we do if we can't send? just block
      # matchSocket.SNDTIMEO = 5000
      if debug: eprint(f"{scriptName}[{reqWorkerId}]:\t🔗\tconnected to sink at {topicPort}")

      # loop until we're told to shut down, or until we run out of projects
      for project in myProjects:

        if shuttingDown:
          break

        totalProjCount.increment()
        tags, classifiers = get_tags(sqlConn, project, offline)
        tagsLen = len(tags) if tags else 0
        classifiersLen = len(classifiers) if classifiers else 0
        if debug:
          eprint(f"{scriptName}[{reqWorkerId}]:\t{'📎' if (tagsLen > 0) else '🅾'}\t{project} ➔ {','.join(tags) if (tagsLen > 0) else ''}")
          eprint(f"{scriptName}[{reqWorkerId}]:\t{'⛿' if (classifiersLen > 0) else '🅾'}\t{project} ➔ {','.join(classifiers) if (classifiersLen > 0) else ''}")

        # if the list of this project's tags contains any of the requested tags from the command line that's a hit
        if (((tagsLen > 0)        and (((len(tagsStr) > 0)        and any(item in tags        for item in tagsStr))        or any(tagsRegEx.search(item)        for item in tags))) or
            ((classifiersLen > 0) and (((len(classifiersStr) > 0) and any(item in classifiers for item in classifiersStr)) or any(classifiersRegEx.search(item) for item in classifiers)))):
          try:
            # Send results to sink
            matchSocket.send_string(project)
            if verboseDebug: eprint(f"{scriptName}[{reqWorkerId}]:\t✅\t{project}")

          except zmq.Again as timeout:
            # todo: what to do here?
            if verboseDebug: eprint(f"{scriptName}[{reqWorkerId}]:\t🕑")

  finally:
    if debug: eprint(f"{scriptName}[{reqWorkerId}]:\t🙃\tfinished")
    reqWorkersCount.decrement()
    finishedWorkersCount.increment()

###################################################################################################
# main
def main():
  global args
  global debug
  global verboseDebug
  global pdbFlagged
  global shuttingDown
  global finishedWorkersCount
  global totalProjCount

  parser = argparse.ArgumentParser(description=scriptName, add_help=False, usage='{} <arguments>'.format(scriptName))
  parser.add_argument('-v', '--verbose', dest='debug', type=str2bool, nargs='?', const=True, default=False, metavar='true|false', help="Verbose/debug output")
  parser.add_argument('--extra-verbose', dest='verboseDebug', help="Super verbose output", metavar='true|false', type=str2bool, nargs='?', const=True, default=False)
  parser.add_argument('-k', '--keyword', dest='tags', action='store', nargs='+', default=[], metavar='<keyword>', help="List of keywords ('exact' or 'r:regex(pr?)?') to case-insensitively match (OR'ed with classifiers)")
  parser.add_argument('-c', '--classifier', dest='classifiers', action='store', nargs='+', default=[], metavar='<classifier>', help="List of classifiers ('exact' or 'r:regex(pr?)?') to case-insensitively match (OR'ed with keywords)")
  parser.add_argument('-p', '--project', dest='projects', action='store', nargs='*', metavar='<project>', help="List of projects to examine")
  parser.add_argument('-d', '--db', dest='dbFileSpec', metavar='<filespec>', type=str, default=None, help='sqlite3 package tags cache database')
  parser.add_argument('-t', '--thread', dest='threads', metavar='<count>', type=int, default=1, help='Request threads')
  parser.add_argument('-o', '--offline', dest='offline', type=str2bool, nargs='?', const=True, default=False, metavar='true|false', help="Offline only (use cache database)")
  try:
    parser.error = parser.exit
    args = parser.parse_args()
  except SystemExit as se:
    eprint(se)
    parser.print_help()
    exit(2)

  verboseDebug = args.verboseDebug
  debug = args.debug or verboseDebug
  if debug:
    eprint(os.path.join(scriptPath, scriptName))
    eprint("Arguments: {}".format(sys.argv[1:]))
    eprint("Arguments: {}".format(args))
  else:
    sys.tracebacklimit = 0

  if (len(args.tags) == 0) and (len(args.classifiers) == 0):
    parser.print_help()
    exit(2)

  # either get projects from command line or entire list from pypi.org
  if (args.projects is not None):
    projects = args.projects
  elif args.offline:
    # will populate in a sec...
    projects = []
  else:
    response = requests.get("https://pypi.org/simple")
    soup = bs(response.text, "lxml")
    projects = [x for x in soup.text.split() if x]

  # handle sigint and sigterm for graceful shutdown
  signal.signal(signal.SIGINT, shutdown_handler)
  signal.signal(signal.SIGTERM, shutdown_handler)
  signal.signal(signal.SIGUSR1, pdb_handler)
  signal.signal(signal.SIGUSR2, debug_toggle_handler)

  # initialize ZeroMQ context and socket(s) to send messages to
  context = zmq.Context()

  # Socket to receive results on
  topicPort = find_free_port()
  matchSocket = context.socket(zmq.PULL)
  matchSocket.bind(f"tcp://*:{topicPort}")
  matchSocket.SNDTIMEO = 5000
  matchSocket.RCVTIMEO = 5000

  if debug: eprint(f"{scriptName}[0]:\t👂\tbound sink port {topicPort}")

  # default to current working directory pypi.db for SQL database
  dbPath = args.dbFileSpec if (args.dbFileSpec is not None) else os.path.join(origPath, 'pypi.db')
  with sqlite3.connect(dbPath, check_same_thread=False) as conn:

    # print out some debug information about the database if requested
    cursor = conn.cursor()
    if verboseDebug:
      eprint(f"SQLite version: {cursor.execute('SELECT SQLITE_VERSION()').fetchone()}")
    execute_statement(conn, SQL_CREATE_PROJECTS_STATEMENT)
    if debug:
      eprint(f"{scriptName}[0]:\t💾\t{TABLE_NAME} count: {cursor.execute(f'SELECT COUNT(*) FROM {TABLE_NAME}').fetchone()}")

    if args.offline and (not projects):
      try:
        projects = [x[0] for x in cursor.execute(f'SELECT {PROJECT_FIELD} FROM {TABLE_NAME}').fetchall()]
      except Exception as e:
        eprint('"{}" raised for offline SELECT'.format(str(e)))

    projects = sorted(projects, key=str.casefold)
    if debug:
      eprint(f"{TABLE_NAME} ({len(projects)}): {projects}")

    # start request threads to lookup the
    reqThreads = ThreadPool(args.threads if args.threads > 0 else 1, reqWorker,
                            ([args.threads, topicPort, projects, args.tags, args.classifiers, conn, args.offline]))

    # wait, collect matching results and print them
    while (not shuttingDown) and (finishedWorkersCount.value() < args.threads):

      if pdbFlagged:
        pdbFlagged = False
        breakpoint()

      try:
        print(matchSocket.recv_string())
      except zmq.Again as timeout:
        tagsResult = None
        if verboseDebug: eprint(f"{scriptName}:\t🕑\t(recv)")

    # one last go around to get any others that might queued
    while (not shuttingDown):
      try:
        print(matchSocket.recv_string())
      except zmq.Again as timeout:
        break

  # graceful shutdown
  if debug: eprint(f"{scriptName}: shutting down ({totalProjCount.value()} processed)...")
  time.sleep(1)

###################################################################################################
if __name__ == '__main__':
  main()
