utils-scripts:
    file.recurse:
        # this state copies the scripts:
        # build_vars, retry, set_local_revision, update_python_dependency, wait_for_port
        # this directory was only available in interactive login shells
        # it was not available to commands executed using su or sudo
        # for example, running a cmd.run state with a user other than root
        # or sudo'ing to root to run a command
        #- name: /usr/local/utils/
        # this directory is always on the PATH
        - name: /usr/local/bin
        - source: salt://elife/utils
        - file_mode: 555

utils-scripts-path:
    file.absent:
        - name: /etc/profile.d/utils-path.sh
