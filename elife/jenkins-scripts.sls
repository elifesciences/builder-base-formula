# Allows jenkins and similar machines to run utilities such as standalone Python scripts
# Requires a jenkins-user-and-group state to be present to declare the jenkins user has been created.
# This can be done either by the jenkins .deb, or manually in the case of a slave.
jenkins-scripts:
    file.recurse:
        - name: /usr/local/jenkins-scripts/
        - source: salt://elife/jenkins-scripts
        - file_mode: 555

slack-channel-hook:
    cmd.run:
        - name: echo 'export SLACK_CHANNEL_HOOK={{ pillar.elife.jenkins.slack.channel_hook }}' > /etc/profile.d/slack-channel-hook.sh

github-token:
    cmd.run:
        - name: |
            rm -f /etc/profile.d/github-commit-status-token.sh
            echo 'export GITHUB_TOKEN={{ pillar.elife.jenkins.github.token }}' > /etc/profile.d/jenkins-github-token.sh

new-relic-rest-api-key:
    cmd.run:
        - name: echo 'export NEW_RELIC_REST_API_KEY={{ pillar.elife.newrelic.rest_api_key }}' > /etc/profile.d/new-relic-rest-api-key.sh

