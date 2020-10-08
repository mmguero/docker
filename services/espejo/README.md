# espejo

Espejo is a Docker-based [apt](https://en.wikipedia.org/wiki/APT_(software)) and [PyPi](https://pypi.org/) package repository mirror using [apt-mirror](https://github.com/apt-mirror/apt-mirror), [bandersnatch](https://github.com/pypa/bandersnatch/) and [nginx](https://nginx.org/en/).

## Configuration

### Configuration files

* `docker-compose.yml` - If you want the directories containing the mirrored apt and pypi packages to reside somewhere other than the default subdirectories in the espejo project directory, edit [`docker-compose.yml`](./docker-compose.yml) and change the volume bind mounts for `/mnt/mirror/debian` and `/mnt/mirror/pypi` so that the host (left) side of the mount reflects the correct locations. You'll need to do this in the `apt-mirror`, `bandersnatch` and `nginx` services' sections.
* `mirror.list` - The list of apt repositories to mirror can be found in [`./config/mirror.list`](./config/mirror.list). This can be modified to mirror other repositories as needed.
* `gpg-key-urls.list` - If you add other third-party repositories to `mirror.list`, you'll need to add the URLs for the GPG keys to [`./config/gpg-key-urls.list`](./config/gpg-key-urls.list) and **rebuild** the apt-mirror service with `docker-compose build apt-mirror`, as the `apt-key add` operation to add these GPG keys to the trusted keystore is performed during build time (not run time).
* `bandersnatch.conf` - The [`bandersnatch.conf`](./config/bandersnatch.conf) file contains [configuration](https://bandersnatch.readthedocs.io/en/latest/mirror_configuration.html) for the PyPi mirror. Pay particular attention to the `blacklist` and `whitelist` sections to filter the set of packages you want to mirror. The `diff-file` value is set, by default, to write status updates about the newly downloaded mirrored packages to write to the directory volume-bound to `/mnt/mirror/pypi-status` in [`docker-compose.yml`](./docker-compose.yml).

### TLS certificates for HTTPS connections

Prior to running espejo, run [`./scripts/auth_setup.sh`](./scripts/auth_setup.sh) to generate self-signed TLS certificates for HTTPS connections.

```
$ ./scripts/auth_setup.sh 

(Re)generate self-signed certificates for HTTPS access [Y/n]? y

$ ls -l certs/
total 8,192
-rw-r--r-- 1 user user 1,805 Oct  8 08:05 cert.pem
-rw------- 1 user user 3,272 Oct  8 08:05 key.pem
```

## Run espejo

1. Run `docker-compose up -d && docker-compose logs -f` to start espejo.
```
$ docker-compose up -d && docker-compose logs -f
Creating network "espejo_default" with the default driver
Creating espejo_apt-mirror_1   ... done
Creating espejo_bandersnatch_1 ... done
Creating espejo_nginx_1        ... done
Attaching to espejo_nginx_1, espejo_bandersnatch_1, espejo_apt-mirror_1
nginx_1         | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
nginx_1         | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
nginx_1         | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
nginx_1         | 10-listen-on-ipv6-by-default.sh: error: ipv6 not available
nginx_1         | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
nginx_1         | /docker-entrypoint.sh: Configuration complete; ready for start up
bandersnatch_1  | usermod: no changes
bandersnatch_1  | bandersnatch
bandersnatch_1  | uid=1000(bandersnatch) gid=1000(bandersnatch) groups=1000(bandersnatch)
bandersnatch_1  | time="2020-10-08T13:03:51Z" level=info msg="read crontab: /etc/crontab"
apt-mirror_1    | apt-mirror
apt-mirror_1    | uid=1000(apt-mirror) gid=1000(apt-mirror) groups=1000(apt-mirror)
apt-mirror_1    | time="2020-10-08T13:03:51Z" level=info msg="read crontab: /etc/crontab"
...
```
2. [Every night at midnight](https://crontab.guru/every-night-at-midnight) the [apt-mirror](./Dockerfiles/apt-mirror.Dockerfile) and [bandersnatch](./Dockerfiles/bandersnatch.Dockerfile) will update their mirrors.
3. To manually force a download (you may wish to run these in a `screen` or `tmux` session, or `nohup` them:
    - `docker-compose exec -u apt-mirror apt-mirror /usr/bin/apt-mirror`
    - `docker-compose exec -u bandersnatch bandersnatch /usr/local/bin/bandersnatch mirror --force-check`

## Using the mirror

### apt

1. Create backups of original sources.list file
    - `cp /etc/apt/sources.list /etc/apt/sources.list.bak`

2. Set up alternate source
    - create `/etc/apt/apt.conf.d/80ssl-exceptions` to ignore self-signed certificate errors from using your apt-mirror
```
Acquire::https {
  Verify-Peer "false";
  Verify-Host "false";
}
```
        
    - modify `/etc/apt/source.list` to point to your apt-mirror:
```
deb https://XXXXXX:443/debian buster main contrib non-free
deb https://XXXXXX:443/debian-security buster/updates main contrib non-free
deb https://XXXXXX:443/debian buster-updates main contrib non-free
deb https://XXXXXX:443/debian buster-backports main contrib non-free
```

3. Perform your `apt` operations (`update`, `upgrade`, `full-upgrade`, etc.)

4. Revert changes to config files if desired

### pip

Use `pip`'s `--index-url` to point to your mirror and `--trusted-host` to ignore self-signed certificate errors from the self-signed certificates

```
`python3 -m pip install --upgrade --index-url=https://XXXXXX:443/pypi/simple --trusted-host=XXXXXX:443 foobar`
```

### Migrating to an off-site location

To deploy `espejo` off-site (such as in an air-gapped location without internet access)

1. Stop espejo
```
$ docker-compose down
```
2. Backup the espejo Docker images
```
$ ./scripts/backup_docker_images.sh
This might take a few minutes...
Packaged espejo docker images to "/home/user/espejo/espejo_20201007_113051_41e6699_images.tar.gz"
```
3. Copy the espejo directory, any directories containing mirrored packages and the backed-up espejo images file to the transfer medium
4. Sneaker-net the transfer medium to the new network and copy the backed-up files and directories from the transfer medium to their new home(s)
5. Load the espejo Docker images
```
$ docker load -i espejo_20201007_113051_41e6699_images.tar.gz
Loaded image: mmguero/espejo_nginx:latest
Loaded image: mmguero/espejo_apt-mirror:latest
Loaded image: mmguero/espejo_bandersnatch:latest 
```
6. Tweak `docker-compose.yml` so that the volume bind mounts reflect the correct locations for the mirrored package directories
7. Start espejo as outlined above in **Run Espejo**
8. Configure clients as outlined above in **Using the mirror**