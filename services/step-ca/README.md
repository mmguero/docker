# setup

* put what will be the intermediate password in secrets.txt, chmod 600
* `docker run --rm -it -v $(pwd)/step:/home/step smallstep/step-ca sh`
    - `step ca init --ssh --name=mypki --dns=step.example.org --address=:9000 --provisioner=myjwk --password-file=/path/to/password1.txt --provisioner-password-file=/path/to/password2.txt`
    - make note of provisioner fingerprint xxxxxxxxxx
    - make note of the cert authority configuration to to add it to the `authorized_keys` on the clients
* `docker-compose up -d`
* `docker-compose exec -u 0 ca sh`
    - `step ca provisioner add acme --type ACME`
* use `step crypto change-pass` to change password for intermediate, ssh_host and ssh_user keys so that it's different from the root CA password (which you had in password1.txt)

# bootstrapping clients

* `step ca bootstrap --ca-url https://step.example.org:9000 --fingerprint xxxxxxxxxx --install`

# HTTPS (ACME)

## traefik

```
version: "3.7"

services:

  traefik:
    image: "traefik:latest"
    container_name: "traefik"
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      - "--certificatesresolvers.myresolver.acme.caserver=https://example.org:9000/acme/acme/directory"
      - "--certificatesresolvers.myresolver.acme.email=admin@example.org"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - 0.0.0.0:80:80
      - 0.0.0.0:443:443
    networks:
      - proxy
    volumes:
      - "./letsencrypt:/letsencrypt:rw"
      - "./certs:/etc/ssl/certs:ro"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    restart: unless-stopped

  whoami:
    image: "containous/whoami"
    container_name: "whoami"
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami.example.org`)"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.tls.certresolver=myresolver"
    restart: unless-stopped

networks:
  proxy:
    external:
      name: traefik-proxy
```

# ssh

* copy `./step/certs/ssh_user_ca_key.pub` from step-ca server to `/etc/ssh_user_ca_key.pub` on network endpoints
* on network endpoints as root

```
$ step ssh certificate --insecure --no-password \
    --ca-url=https://step.example.org:9000/ \
    --root=/usr/local/share/ca-certificates/mypki_Root_CA_###########.crt \
    --provisioner=myjwk --host endpoint.example.org \
    /etc/ssh_host_ecdsa_key

$ step ssh certificate --host --sign \
    --ca-url=https://step.example.org:9000/ \
    --root=/usr/local/share/ca-certificates/mypki_Root_CA_###########.crt \
    --provisioner=myjwk endpoint.example.org \
    /etc/ssh_host_ecdsa_key.pub
```

* edit `/etc/ssh/sshd_config` and append:

```
# SSH CA Configuration
# The path to the CA public key for authenticating user certificates
TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
# Path to the private key and certificate
HostKey /etc/ssh/ssh_host_ecdsa_key
HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub
```

```
$ systemctl daemon-reload
$ systemctl restart ssh
```

* create `/etc/cron.weekly/rotate-ssh-certificate`

```
#!/bin/sh

step ssh renew --force \
  --ca-url=https://step.example.org:9000/ \
  --root=/usr/local/share/ca-certificates/mypki_Root_CA_###########.crt \
  --provisioner=sshpop \
  /etc/ssh/ssh_host_ecdsa_key-cert.pub /etc/ssh/ssh_host_ecdsa_key
```

* on clients
    - to provision key: `step ssh certificate --provisioner=myjqk --principal=user --principal=username user@endpoint.exmple.org ~/.ssh/id_ecdsa`
    - add cert authority configuration to the `authorized_keys`

# links

https://smallstep.com/blog/build-a-tiny-ca-with-raspberry-pi-yubikey/
https://smallstep.com/docs/tutorials/docker-tls-certificate-authority
https://smallstep.com/blog/use-ssh-certificates/
https://smallstep.com/blog/diy-single-sign-on-for-ssh/
https://www.whatsdoom.com/posts/2020/02/29/ssh-certificates-with-step-ca/