<?php

// where to get files from
const ENTRY_FIELD = array('filepond');

// where to write files to
const TRANSFER_DIR = __DIR__ . '/tmp';
const UPLOAD_DIR = __DIR__ . '/files';
const VARIANTS_DIR = __DIR__ . '/variants';

// name to use for the file metadata object
const METADATA_FILENAME = '.metadata';

// allowed file formats, if empty all files allowed
const ALLOWED_FILE_FORMATS = array(
    'application/gzip',
    'application/octet-stream',
    'application/vnd.tcpdump.pcap',
    'application/x-7z-compressed',
    'application/x-bzip2',
    'application/x-cpio',
    'application/x-gzip',
    'application/x-lzip',
    'application/x-lzma',
    'application/x-pcapng',
    'application/x-rar-compressed',
    'application/x-tar',
    'application/x-xz',
    'application/zip'
);

if (!is_dir(UPLOAD_DIR)) mkdir(UPLOAD_DIR, 0755);
if (!is_dir(TRANSFER_DIR)) mkdir(TRANSFER_DIR, 0755);
if (!is_dir(VARIANTS_DIR)) mkdir(VARIANTS_DIR, 0755);
