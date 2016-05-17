#!/bin/bash
echo "this is the body" | mail -s "this is the subject" "{{ pillar.elife.deploy_user.email }}"
