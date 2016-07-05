import logging

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
