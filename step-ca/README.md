# setup

* enter a directory where you want `step-ca` to live
* `mkdir -p step/{certs,config,db,secrets,templates}`
* ensure you've got the `docker-compose.yml` from this repository in your directory
* put what will be serve as the root CA password in `secrets.txt` and your provisioner pasword in `provisioner.txt`
* `chmod 600 secrets.txt provisioner.txt`
* `docker run --rm -it -u 0 -v $(pwd)/step:/home/step -v $(pwd)/secrets.txt:/secrets.txt:ro -v $(pwd)/provisioner.txt:/provisioner.txt:ro smallstep/step-ca sh`
    - `step ca init --ssh --name=mypki --dns=step.example.org --address=:9000 --provisioner=myjwk --password-file=/secrets.txt --provisioner-password-file=/provisioner.txt`
    - make note of provisioner fingerprint `xxxxxxxxxx` to use for bootstrapping clients
* `docker-compose up -d ; sleep 10; docker-compose logs`
* `docker-compose exec -u 0 ca sh`
    - `step ca provisioner add acme --type ACME`
* use `step crypto change-pass` to change password for intermediate, `ssh_host` and `ssh_user` keys so that it's different from the root CA password (which you had in `password1.txt`)
  - `docker-compose exec -u 0 ca sh`
      + `step crypto change-pass /home/step/secrets/intermediate_ca_key`
      + etc.
* `docker-compose down`
* change the contents of `secrets.txt` to contain the new intermediate password you just set with `step crypto change-pass`
* you don't need the `provisioner.txt` file any more (though you will need that password for manually provisioning certificates), so securely delete it
    + `shred -u provisioner.txt`
* `docker-compose up -d ; sleep 10; docker-compose logs`

## OIDC/OAuth

(from [DIY Single Sign-On for SSH](https://smallstep.com/blog/diy-single-sign-on-for-ssh/))

**Create a Google OAuth Credential** - You’ll need a [Google OAuth 2.0 Credential](https://console.cloud.google.com/apis/credentials/oauthclient) for this project. This takes 2 minutes.

* Create a [Google Cloud Console Project](https://console.cloud.google.com/projectcreate) if you don’t have one
  * Create the project in the GSuite Organization that you will use for single sign on (if you're using GSuite).
* [Configure the OAuth 2.0 consent screen](https://console.developers.google.com/apis/credentials/consent) for an Internal project
  * Note: as I'm not using GSuite, I wasn't able to do *Internal* but *External* worked ok.
* Create an [OAuth 2.0 credential](https://console.developers.google.com/apis/credentials/oauthclient)
  * For *Application Type*, choose *Desktop app*

Jot down the Client ID and Client Secret; you’ll need them for the next step!

```
  step ca provisioner add google \
    --type=oidc --ssh \
    --client-id=123456789009-casdfa97asdfcasdf8jklj89090fasd1.apps.googleusercontent.com \
    --client-secret=asdfFACSDsadf304JSDAcsl4 \
    --configuration-endpoint https://accounts.google.com/.well-known/openid-configuration \
    --admin=example@gmail.com \
    --domain=gmail.com
```

You only need to specify `admin` if you want the account your authenticating to Google with to be able to provision keys for other principals. If you're using gsuite and have another domain, obviously use that.

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

* copy `./step/certs/ssh_user_ca_key.pub` from step-ca server to `/etc/ssh/ssh_user_ca_key.pub` on network endpoints
* on network endpoints as root

```
$ step ssh certificate --insecure --no-password \
    --ca-url=https://step.example.org:9000/ \
    --root=/usr/local/share/ca-certificates/mypki_Root_CA_###########.crt \
    --provisioner=myjwk --host endpoint.example.org \
    /etc/ssh/ssh_host_ecdsa_key

$ step ssh certificate --host --sign \
    --ca-url=https://step.example.org:9000/ \
    --root=/usr/local/share/ca-certificates/mypki_Root_CA_###########.crt \
    --provisioner=myjwk endpoint.example.org \
    /etc/ssh/ssh_host_ecdsa_key.pub
```

* edit `/etc/ssh/sshd_config` and append:

```
# SSH CA Configuration
# The path to the CA public key for authenticating user certificates
TrustedUserCAKeys /etc/ssh/ssh_user_ca_key.pub
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
    - add cert authority configuration to the `known_hosts` by concatenating `@cert-authority * ` and the contents of `./step/certs/ssh_host_ca_key.pub` from the CA server

# links

* https://smallstep.com/blog/build-a-tiny-ca-with-raspberry-pi-yubikey/
* https://smallstep.com/docs/tutorials/docker-tls-certificate-authority
* https://smallstep.com/blog/use-ssh-certificates/
* https://smallstep.com/blog/diy-single-sign-on-for-ssh/
* https://www.whatsdoom.com/posts/2020/02/29/ssh-certificates-with-step-ca/