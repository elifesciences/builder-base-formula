# allows jenkins and similar machines to run utilities such as standalone Python scripts
jenkins-scripts:
    file.recurse:
        - name: /usr/local/jenkins-scripts/
        - user: jenkins
        - source: salt://elife/jenkins-scripts
        - file_mode: 555

slack-channel-hook:
    cmd.run:
        - name: echo 'export SLACK_CHANNEL_HOOK={{ pillar.alfred.slack.channel_hook }}' > /etc/profile.d/slack-channel-hook.sh
