0. Stop previous OpenSearch instance, if running:

```bash
$ docker compose down --volumes
```

1. Generate self-signed certificates:

```bash
$ pushd ./certs
$ ./generate-certificates.sh
Certificate request self-signature ok
subject=C = US, ST = IDAHO, L = Rexburg, O = Development, OU = Testing, CN = admin
Certificate request self-signature ok
subject=C = US, ST = IDAHO, L = Rexburg, O = Development, OU = Testing, CN = node1.dns.a-record
Certificate request self-signature ok
subject=C = US, ST = IDAHO, L = Rexburg, O = Development, OU = Testing, CN = node2.dns.a-record
Certificate request self-signature ok
subject=C = US, ST = IDAHO, L = Rexburg, O = Development, OU = Testing, CN = node3.dns.a-record
Certificate request self-signature ok
subject=C = US, ST = IDAHO, L = Rexburg, O = Development, OU = Testing, CN = node4.dns.a-record
Certificate request self-signature ok
subject=C = US, ST = IDAHO, L = Rexburg, O = Development, OU = Testing, CN = client.dns.a-record
$ popd
```

2. Copy `.creds.curlrc.example` to `.creds.curlrc` and change the username and password

3. Set the username and password (hashed) from `.creds.curlrc` into `./security/internal_users.yml`:

```bash
$ USERNAME="$(sed -n 's/^user: *"\([^:]*\):[^"]*"/\1/p' ./.creds.curlrc | head -n1)"
$ PASSWORD_HASH="$(PASSWORD_ENV=$(sed -n 's/^user: *"[^:]*:\([^"]*\)"/\1/p' ./.creds.curlrc | head -n 1) \
    docker run --rm -e PASSWORD_ENV \
    --entrypoint=/usr/share/opensearch/plugins/opensearch-security/tools/hash.sh oci.guero.org/opensearch:latest \
    -env PASSWORD_ENV --algorithm BCrypt)"
$ awk -v newuser="$USERNAME" -v newhash="$PASSWORD_HASH" '
  BEGIN { in_admin = 0 }
  /^\s*admin:/ {
    in_admin = 1
    sub(/^admin:/, newuser ":")
    print
    next
  }
  /^\S/ && !/^admin:/ && in_admin {
    in_admin = 0
  }
  in_admin && /^\s*hash:/ {
    gsub(/\$|\\/, "\\\\&", newhash)
    print gensub(/^( *hash: ).*$/, "\\1\"" newhash "\"", 1)
    next
  }
  {
    print
  }
' security/internal_users.yml > security/internal_users.new.yml && mv security/internal_users.new.yml security/internal_users.yml
```

4. Edit `docker-compose.yml` and adjust resources if needed
    * `-Xms` and `-Xmx` in `OPENSEARCH_JAVA_OPTS` for each OpenSearch node 
    * The defaults in `docker-compose.yml` assume your host system has 64GB RAM

5. Start OpenSearch

```bash
$ docker compose up --detach
```

6. After about a minute, setup security plugin:

```bash
$ ./security-admin-docker-compose.sh
Security Admin v7
Will connect to localhost:9200 ... done
Connected as "CN=admin,OU=Testing,O=Development,L=Rexburg,ST=IDAHO,C=US"
OpenSearch Version: 3.0.0
Contacting opensearch cluster 'opensearch' and wait for YELLOW clusterstate ...
Clustername: opensearch-cluster
Clusterstate: GREEN
Number of nodes: 4
Number of data nodes: 2
.opendistro_security index does not exists, attempt to create it ... done (0-all replicas)
Populate config from /usr/share/opensearch/config/opensearch-security/
Will update '/config' with /usr/share/opensearch/config/opensearch-security/config.yml
   SUCC: Configuration for 'config' created or updated
Will update '/roles' with /usr/share/opensearch/config/opensearch-security/roles.yml
   SUCC: Configuration for 'roles' created or updated
Will update '/rolesmapping' with /usr/share/opensearch/config/opensearch-security/roles_mapping.yml
   SUCC: Configuration for 'rolesmapping' created or updated
Will update '/internalusers' with /usr/share/opensearch/config/opensearch-security/internal_users.yml
   SUCC: Configuration for 'internalusers' created or updated
Will update '/actiongroups' with /usr/share/opensearch/config/opensearch-security/action_groups.yml
   SUCC: Configuration for 'actiongroups' created or updated
Will update '/tenants' with /usr/share/opensearch/config/opensearch-security/tenants.yml
   SUCC: Configuration for 'tenants' created or updated
Will update '/nodesdn' with /usr/share/opensearch/config/opensearch-security/nodes_dn.yml
   SUCC: Configuration for 'nodesdn' created or updated
Will update '/audit' with /usr/share/opensearch/config/opensearch-security/audit.yml
   SUCC: Configuration for 'audit' created or updated
Will update '/allowlist' with /usr/share/opensearch/config/opensearch-security/allowlist.yml
   SUCC: Configuration for 'allowlist' created or updated
SUCC: Expected 9 config types for node {"updated_config_types":["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"],"updated_config_size":9,"message":null} is 9 (["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"]) due to: null
SUCC: Expected 9 config types for node {"updated_config_types":["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"],"updated_config_size":9,"message":null} is 9 (["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"]) due to: null
SUCC: Expected 9 config types for node {"updated_config_types":["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"],"updated_config_size":9,"message":null} is 9 (["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"]) due to: null
SUCC: Expected 9 config types for node {"updated_config_types":["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"],"updated_config_size":9,"message":null} is 9 (["allowlist","tenants","rolesmapping","nodesdn","audit","roles","actiongroups","config","internalusers"]) due to: null
Done with success
```

7. Monitor logs (optional):

```bash
$ docker compose logs --follow
```

8. Connect to dashboards at https://localhost:5601
