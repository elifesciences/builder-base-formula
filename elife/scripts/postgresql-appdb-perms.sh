#!/bin/bash
# fixes any existing permissions and grants future permissions 

set -x

host={{ host }}
port={{ port }}
db={{ db_name }}

# app user
user={{ app_user_name }}
pass={{ app_user_pass }}

# rootuser
rootuser={{ user }}
rootpass={{ pass }}

PGPASSWORD=$pass psql -U $user -h $host -p $port $db -c "
-- can't alter default privileges (later) for app user if rootuser not in same role
-- you get ERROR:  must be member of role '<appuser>'
GRANT $user TO $rootuser;

-- ensure the root user has all permissions neccessary. if this is a legacy db,
-- then the app user may be the owner with all of the permissions. if it's not,
-- this statement will fail as the app user no longer has enough permissions.
GRANT ALL ON DATABASE $db TO $rootuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $rootuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $rootuser;

-- ensure all future objects can be read
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO $rootuser;"

PGPASSWORD=$rootpass psql -U $rootuser -h $host -p $port postgres -c "
-- cannot be run on the target database
ALTER DATABASE $db OWNER TO $rootuser;"

set -e

PGPASSWORD=$rootpass psql -U $rootuser -h $host -p $port $db -c "
-- ensure the app user can do most anything it needs to with the app db
GRANT ALL ON DATABASE $db TO $user;
GRANT ALL ON ALL TABLES IN SCHEMA public TO $user;
ALTER DEFAULT PRIVILEGES FOR USER $user GRANT ALL ON tables TO $user;
ALTER DEFAULT PRIVILEGES FOR USER $user GRANT ALL ON sequences TO $user;"

echo "permissions set"
