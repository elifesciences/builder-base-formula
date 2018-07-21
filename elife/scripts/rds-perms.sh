#!/bin/bash
# it's a little backwards, but because the rds_superuser doesn't get permissions
# on new objects, it has to be granted them. 
set -ex

{% if salt['elife.cfg']('cfn.outputs.RDSHost') %} 

host={{ salt['elife.cfg']('cfn.outputs.RDSHost') }}
port={{ salt['elife.cfg']('cfn.outputs.RDSPort') }}
{% if otherdb is defined %}
db={{ otherdb }}
{% else %}
db={{ salt['elife.cfg']('project.rds_dbname') }}
{% endif %}
pass={{ pass }}
user={{ user }}

rootuser={{ salt['elife.cfg']('project.rds_username') }}
rootpass={{ salt['elife.cfg']('project.rds_password') }}

PGPASSWORD=$pass psql -U $user -h $host -p $port $db -c "
-- possibly redundant
GRANT ALL ON DATABASE $db TO rds_superuser;
-- the important bit
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rds_superuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rds_superuser;
-- ensure all future objects can be read
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO rds_superuser;"

# in some instances where the database has been destroyed and recreated, it's 
# been done so as the application user. this re-assigns ownership back to the
# root user who is in possession of the 'rds_superuser' role.
PGPASSWORD=$rootpass psql -U $rootuser -h $host -p $port postgres -c "ALTER DATABASE $db OWNER TO $rootuser;"

echo "rds_superuser permissions set"

{% else %}

echo "no rds permissions to set"

{% endif %}
