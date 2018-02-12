#!/bin/bash
# sets permissions on new databases

set -x

host={{ host }}
port={{ port }}
db={{ db_name }}

rootuser={{ user }}
rootpass={{ pass }}

PGPASSWORD=$rootpass psql -U $rootuser -h $host -p $port $db -c "
-- ensure the root user has all permissions neccessary.
GRANT ALL ON DATABASE $db TO $rootuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $rootuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $rootuser;

-- ensure all future objects can be read
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO $rootuser;"

echo "permissions set"
