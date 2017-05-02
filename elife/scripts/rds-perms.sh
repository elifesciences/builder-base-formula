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

PGPASSWORD=$pass psql -U $user -h $host -p $port $db -c "
-- possibly redundant
GRANT ALL ON DATABASE $db TO rds_superuser;
-- the important bit
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rds_superuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rds_superuser;
-- ensure all future objects can be read
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO rds_superuser;"

echo "rds_superuser permissions set"

{% else %}

echo "no rds permissions to set"

{% endif %}
