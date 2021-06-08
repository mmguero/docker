# Zeek, dockerized

A simple Docker container for [zeek/zeek](https://github.com/zeek/zeek), including the [zeek/spicy](https://github.com/zeek/spicy) parser generator. The Docker image itself is large-ish (> 1GB) because it retains the build environment packages necessary to build and use spicy plugins.

Also included is a [zeek-docker.sh](zeek-docker.sh) bash wrapper script for running Zeek against a PCAP file or network interface.

## Examples

### With Wrapper Script

#### Local `zeek` Scripts

If there are any `*.zeek` files in the same absolute path as `zeek-docker.sh` they will be passed along to zeek as additional scripts in addition to the default `local` policy. If any of these `*.zeek` files begins with `local` (for example, the [`local-example.zeek`](local-example.zeek) file included in this repository), then the [default](https://github.com/zeek/zeek/blob/master/scripts/site/local.zeek) `local` policy will not be used.

To understand which local `*.zeek` scripts will be used when we run `zeek-docker.sh`:

```
user@host tmp › ls -l $(dirname $(realpath $(which zeek-docker.sh)))/
total 32,768
-rw-r--r-- 1 user user 6,852 Jun  8 07:44 Dockerfile
-rw-r--r-- 1 user user 1,724 May 18 11:21 local-example.zeek
-rw-r--r-- 1 user user 8,874 May 18 11:21 login.zeek
-rw-r--r-- 1 user user 1,689 Jun  8 08:58 README.md
-rwxr-xr-x 1 user user 3,535 Jun  8 08:41 zeek-docker.sh
```

It looks like `local-example.zeek` and `login.zeek` will be used by `zeek`. Since `local-example.zeek` is prefixed with `local`, the default `local` policy will not be used.

#### PCAP files

`zeek` will be run (with up to `$MAX_ZEEK_PROCS` concurrent processes, 4 being the default) for each file specified as arguments to `zeek-docker.sh`:

```
user@host tmp › ll
total 4.9G
-rw-r--r-- 1 user user  64M Jun  8 09:08 m57patents-2009-11-13-0924.pcap
-rw-r--r-- 1 user user 6.7M Jun  8 09:08 m57patents-2009-11-14-0924.pcap
…
-rw-r--r-- 1 user user 1.7M Jun  8 09:08 m57patents-2009-12-12-1200.pcap
-rw-r--r-- 1 user user 1.7M Jun  8 09:08 m57patents-2009-12-13-1200.pcap
user@host tmp › zeek-docker.sh *.pcap

user@host tmp › zeek-docker.sh *.pcap
usermod: no changes
zeekcap
uid=1000(zeekcap) gid=1000(zeekcap) groups=1000(zeekcap)
WARNING: No Site::local_nets have been defined.  It's usually a good idea to define your local networks.
…
usermod: no changes
zeekcap
uid=1000(zeekcap) gid=1000(zeekcap) groups=1000(zeekcap)
WARNING: No Site::local_nets have been defined.  It's usually a good idea to define your local networks.

user@host tmp › ls -l 
total 4,875,653,120
drwxr-xr-x 2 user user       4,096 Jun  8 09:09 m57patents-2009-11-13-0924.pcap_logs
…
drwxr-xr-x 2 user user         252 Jun  8 09:10 m57patents-2009-12-13-1200.pcap_logs
-rw-r--r-- 1 user user  63,802,118 Jun  8 09:08 m57patents-2009-11-13-0924.pcap
…
-rw-r--r-- 1 user user   1,616,668 Jun  8 09:08 m57patents-2009-12-13-1200.pcap

user@host tmp › ls -l m57patents-2009-11-13-0924.pcap_logs/
total 3,403,776
-rw-r--r-- 1 user user 1,070,141 Jun  8 09:09 conn.log
-rw-r--r-- 1 user user    27,293 Jun  8 09:09 dhcp.log
-rw-r--r-- 1 user user 1,036,712 Jun  8 09:09 dns.log
-rw-r--r-- 1 user user     1,490 Jun  8 09:09 dpd.log
-rw-r--r-- 1 user user   324,118 Jun  8 09:09 files.log
-rw-r--r-- 1 user user   411,965 Jun  8 09:09 http.log
-rw-r--r-- 1 user user     3,252 Jun  8 09:09 known_certs.log
-rw-r--r-- 1 user user     4,805 Jun  8 09:09 known_hosts.log
-rw-r--r-- 1 user user     7,536 Jun  8 09:09 known_services.log
-rw-r--r-- 1 user user     4,793 Jun  8 09:09 notice.log
-rw-r--r-- 1 user user   368,858 Jun  8 09:09 ntp.log
-rw-r--r-- 1 user user       254 Jun  8 09:09 packet_filter.log
-rw-r--r-- 1 user user       829 Jun  8 09:09 pe.log
-rw-r--r-- 1 user user    49,455 Jun  8 09:09 smb_cmd.log
-rw-r--r-- 1 user user     4,397 Jun  8 09:09 smb_mapping.log
-rw-r--r-- 1 user user    20,341 Jun  8 09:09 software.log
-rw-r--r-- 1 user user     8,383 Jun  8 09:09 ssl.log
-rw-r--r-- 1 user user       393 Jun  8 09:09 weird.log
-rw-r--r-- 1 user user     6,428 Jun  8 09:09 x509.log

user@host tmp › bat m57patents-2009-11-13-0924.pcap_logs/weird.log 
───────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: m57patents-2009-11-13-0924.pcap_logs/weird.log
───────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #separator \x09
   2   │ #set_separator  ,
   3   │ #empty_field    (empty)
   4   │ #unset_field    -
   5   │ #path   weird
   6   │ #open   2021-06-08-15-09-04
   7   │ #fields ts  uid id.orig_h   id.orig_p   id.resp_h   id.resp_p   name    addl    notice  peer    source
   8   │ #types  time    string  addr    port    addr    port    string  string  bool    string  string
   9   │ 1258148297.459715   CmoX6h3pNZFExIFH2e  192.168.1.3 54281   204.9.163.158   80  bad_HTTP_request    -   F   zeek    HTTP
  10   │ #close  2021-06-08-15-09-07
───────┴──────────────────────────────────
```

For each PCAP file scanned, a directory (suffixed with `_logs`) will be created in which the log files will be generated.

#### Network Interfaces

```
user@host tmp › ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 26:57:2d:27:3f:1f brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.2/24 brd 192.168.10.255 scope global dynamic noprefixroute enp0s25
       valid_lft 51842sec preferred_lft 51842sec
…

user@host tmp › zeek-docker.sh enp0s25
usermod: no changes
zeekcap
uid=1000(zeekcap) gid=1000(zeekcap) groups=1000(zeekcap)
listening on enp0s25
…
```

Note that interrupting `zeek-docker.sh` with **`CTRL+C`** will leave the container running in the background, so you'll need to stop it manually when you're ready:

```
user@host tmp › docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED              STATUS              PORTS     NAMES
df08f961e760   mmguero/zeek:latest   "/usr/local/bin/dock…"   About a minute ago   Up About a minute             flamboyant_spence

user@host tmp › docker stop flamboyant_spence 
flamboyant_spence

user@host tmp › ls -l
total 0
drwxr-xr-x 2 user user 182 Jun  8 09:20 enp0s25_logs

user@host tmp › ls -l enp0s25_logs/
total 45,056
-rw-r--r-- 1 user user 7,972 Jun  8 09:20 conn.log
-rw-r--r-- 1 user user 4,513 Jun  8 09:20 dns.log
-rw-r--r-- 1 user user 1,159 Jun  8 09:20 files.log
-rw-r--r-- 1 user user   414 Jun  8 09:20 known_certs.log
-rw-r--r-- 1 user user   436 Jun  8 09:20 known_hosts.log
-rw-r--r-- 1 user user   594 Jun  8 09:20 known_services.log
-rw-r--r-- 1 user user   227 Jun  8 09:18 packet_filter.log
-rw-r--r-- 1 user user 2,131 Jun  8 09:20 ssl.log
-rw-r--r-- 1 user user 1,151 Jun  8 09:20 x509.log
```

For each network interface monitored, a directory (suffixed with `_logs`) will be created in which the log files will be generated.

### Without Wrapper Script

* Monitor a local network interface with Zeek:

```
   docker run --rm \
     -v "$(pwd):/zeek-logs" \
     --network host \
     --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=IPC_LOCK \
     mmguero/zeek:latest \
     zeekcap -i enp6s0 local
```

* Analyze a PCAP file with Zeek:

```
   docker run --rm \
     -v "$(pwd):/zeek-logs" \
     -v "/path/containing/pcap:/data:ro" \
     mmguero/zeek:latest \
     zeek -C -r /data/foobar.pcap local
```

* Use a custom policy:

```
   docker run --rm \
     -v "$(pwd):/zeek-logs" \
     -v "/path/containing/pcap:/data:ro" \
     -v "/path/containing/policy/local-example.zeek:/opt/zeek/share/zeek/site/local.zeek:ro" \
     mmguero/zeek:latest \
     zeek -C -r /data/foobar.pcap local
```

## Extending with `zkg`

Here's an example `Dockerfile` installing [`zeek/spicy-analyzers`](https://github.com/zeek/spicy-analyzers).

```
FROM mmguero/zeek:latest

RUN zkg install --force spicy-analyzers
```

Build and check:

```
user@host tmp › docker build -t=spicier .
Sending build context to Docker daemon  2.048kB
Step 1/2 : FROM mmguero/zeek:latest
 ---> 1a2ccddc1428
Step 2/2 : RUN zkg install --force spicy-analyzers
 ---> Running in 9f7121dc5248
Running unit tests for "zeek/zeek/spicy-analyzers"
Installing "zeek/zeek/spicy-analyzers"............................................................................................................................................................................................................................................................
Installed "zeek/zeek/spicy-analyzers" (v0.2.14)
Loaded "zeek/zeek/spicy-analyzers"
Removing intermediate container 9f7121dc5248
 ---> 667703df1702
Successfully built 667703df1702
Successfully tagged spicier:latest

user@host tmp › docker images | head -n 2
REPOSITORY                                   TAG           IMAGE ID       CREATED             SIZE
spicier                                      latest        667703df1702   30 seconds ago      2.02GB

user@host tmp › docker run --rm --entrypoint=/opt/zeek/bin/zeek spicier:latest -NN | tail -n 40

_Zeek::Spicy - Support for Spicy parsers (*.spicy, *.evt, *.hlto) (dynamic, version 1.1.1)
    [Analyzer] spicy_DHCP (ANALYZER_SPICY_DHCP, enabled)
    [Analyzer] spicy_DNS (ANALYZER_SPICY_DNS, enabled)
    [Analyzer] spicy_HTTP (ANALYZER_SPICY_HTTP, enabled)
    [Analyzer] spicy_LDAP_TCP (ANALYZER_SPICY_LDAP_TCP, enabled)
    [Analyzer] spicy_OpenVPN_TCP (ANALYZER_SPICY_OPENVPN_TCP, enabled)
    [Analyzer] spicy_OpenVPN_TCP_HMAC (ANALYZER_SPICY_OPENVPN_TCP_HMAC, enabled)
    [Analyzer] spicy_OpenVPN_UDP (ANALYZER_SPICY_OPENVPN_UDP, enabled)
    [Analyzer] spicy_OpenVPN_UDP_HMAC (ANALYZER_SPICY_OPENVPN_UDP_HMAC, enabled)
    [File Analyzer] spicy_PE (ANALYZER_SPICY_PE)
    [File Analyzer] spicy_PNG (ANALYZER_SPICY_PNG)
    [Analyzer] spicy_TFTP (ANALYZER_SPICY_TFTP, enabled)
    [Analyzer] spicy_Wireguard (ANALYZER_SPICY_WIREGUARD, enabled)
    [File Analyzer] spicy_ZIP (ANALYZER_SPICY_ZIP)
    [Analyzer] spicy_ipsec_ike_udp (ANALYZER_SPICY_IPSEC_IKE_UDP, enabled)
    [Analyzer] spicy_ipsec_tcp (ANALYZER_SPICY_IPSEC_TCP, enabled)
    [Analyzer] spicy_ipsec_udp (ANALYZER_SPICY_IPSEC_UDP, enabled)
…
```

After building your derivative image, you could run it directly or run `zeek-docker.sh` with a `ZEEK_DOCKER_IMAGE` environment variable containing the name of your image.
