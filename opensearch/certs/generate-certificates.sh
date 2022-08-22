#!/bin/bash

set -e

ENCODING="utf-8"

COUNTRY="US"
STATE="IDAHO"
LOCALITY="Rexburg"
ORGANIZATION="Development"
UNIT="Testing"
NODE_COUNT=3
while getopts 'vc:s:l:o:n:u' OPTION; do
  case "$OPTION" in
    v)
      set -x
      ;;

    c)
      COUNTRY="$OPTARG"
      ;;

    s)
      STATE="$OPTARG"
      ;;

    l)
      LOCALITY="$OPTARG"
      ;;

    o)
      ORGANIZATION="$OPTARG"
      ;;

    u)
      UNIT="$OPTARG"
      ;;

    n)
      NODE_COUNT="$OPTARG"
      ;;

    ?)
      echo "script usage: $(basename $0) [-v] [-c <Country>] [-s <State/Province>] [-l <City/Locality>] [-o <Organization>] [-u <Unit>] [-n <NodeCount>]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

# from https://opensearch.org/docs/latest/security-plugin/configuration/generate-certificates/#sample-script

# Root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=root.dns.a-record" -out root-ca.pem -days 730

# Admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=admin" -out admin.csr
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 730

# Nodes
for NODENUM in $(seq 1 "$NODE_COUNT"); do
  openssl genrsa -out node${NODENUM}-key-temp.pem 2048
  openssl pkcs8 -inform PEM -outform PEM -in node${NODENUM}-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node${NODENUM}-key.pem
  openssl req -new -key node${NODENUM}-key.pem -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=node${NODENUM}.dns.a-record" -out node${NODENUM}.csr
  cat <<EOF > node${NODENUM}.ext
[ req ]
req_extensions = req_ext

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = node${NODENUM}.dns.a-record
EOF
  openssl x509 -req -in node${NODENUM}.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node${NODENUM}.pem -days 730 -extensions req_ext -extfile node${NODENUM}.ext
done

# glauth cert
openssl genrsa -out glauth-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in glauth-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out glauth-key.pem
openssl req -new -key glauth-key.pem -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=glauth.dns.a-record" -out glauth.csr
cat <<EOF > glauth.ext
[ req ]
req_extensions = req_ext

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = glauth.dns.a-record
EOF
openssl x509 -req -in glauth.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out glauth.pem -days 730 -extensions req_ext -extfile glauth.ext

# Client cert
openssl genrsa -out client-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out client-key.pem
openssl req -new -key client-key.pem -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${UNIT}/CN=client.dns.a-record" -out client.csr
cat <<EOF > client.ext
[ req ]
req_extensions = req_ext

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = client.dns.a-record
EOF
openssl x509 -req -in client.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out client.pem -days 730 -extensions req_ext -extfile client.ext

# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node*-key-temp.pem
rm node*.csr
rm node*.ext
rm client-key-temp.pem
rm client.csr
rm client.ext
rm glauth-key-temp.pem
rm glauth.csr
rm glauth.ext
chmod 600 *.pem