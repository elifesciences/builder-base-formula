import logging
import os

log = logging.getLogger(__name__)

def environ_setenv_sensitive(**kwargs):
    '''
    This state works as environ.setenv, but avoids printing the values of
    environment variables, considering them sensitive (e.g. a Github token).

    See 'environ.setenv' for parameters, which are passed to it transparently.

    Example of output:
    ```
    ==> journal--vagrant:           ID: composer-auth
    ==> journal--vagrant:     Function: builder.environ_setenv_sensitive
    ==> journal--vagrant:         Name: COMPOSER_AUTH
    ==> journal--vagrant:       Result: True
    ==> journal--vagrant:      Comment: Environ values were set
    ==> journal--vagrant:      Started: 08:37:04.437606
    ==> journal--vagrant:     Duration: 2.722 ms
    ==> journal--vagrant:      Changes:
    ==> journal--vagrant:               ----------
    ==> journal--vagrant:               COMPOSER_AUTH:
    ==> journal--vagrant:                   ***SENSITIVE***
    '''
    ret = __states__['environ.setenv'](**kwargs)
    ret['changes'] = {key: '***SENSITIVE***' for key in ret['changes']}
    return ret

def git_latest(**kwargs):
    '''
    This state allows extending the behavior of git.latest by passing
    additional parameters:

    fetch_pull_requests
        Performs a `git fetch '*refs/pull/*:refs/pull/*' before 
        starting, to ensure the head and merge commits of PRs
        are available as a revision to switch to.
    '''
    fetch_pull_requests = kwargs.pop('fetch_pull_requests', False)
    target = kwargs.get('target')
    git_repository_exists = os.path.isdir(target)
    if fetch_pull_requests and git_repository_exists:
        refspecs = [
            '+refs/pull/*:refs/pull/*',
        ]
        _fetch_changes = __salt__['git.fetch'](
            target,
            remote=kwargs.get('remote', 'origin'),
            force=True,
            refspecs=refspecs,
            user=kwargs.get('user'),
            identity=kwargs.get('identity')
        )
    ret = __states__['git.latest'](**kwargs)
    return ret
