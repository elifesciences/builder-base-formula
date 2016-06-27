from functools import partial
import os, json
from datetime import datetime
import requests
import base64

import logging
LOG = logging.getLogger(__name__)

def first(x):
    try:
        return x[0]
    except (IndexError, KeyError, TypeError):
        return None

def firstnn(lst):
    "returns first non-nil value in lst or None"
    return first(filter(None, lst))
    
def lookup(data, path, default=0xDEADBEEF):
    try:
        bits = path.split('.', 1)
        if len(bits) > 1:
            bit, rest = bits
        else:
            bit, rest = bits[0], []
        val = data[bit]
        if rest:
            return lookup(val, rest, default)
        return val
    except KeyError:
        if default == 0xDEADBEEF:
            raise
        return default

def once_a_day(key, func):
    "simplistic cache that expires result once a day"
    # ll: /tmp/salt-20151231-foobar.cache
    key = key.replace('/', '--')
    keyfile = '/tmp/salt-' + datetime.now().strftime('%Y%m%d-') + key + '.cache'
    if os.path.exists(keyfile):
        LOG.info("cache hit! %r", keyfile)
        return json.load(open(keyfile, 'r'))
    LOG.info("cache miss! %r", keyfile)
    resp = func()
    json.dump(resp, open(keyfile, 'w'))
    return resp

def acme_enabled(url):
    "if given url can be hit and it looks like the acme hidden dir exists, return True."
    url = 'http://' + url + "/.well-known/acme-challenge/" # ll: http://lax.elifesciences.org/.well-known/acme-challenge
    LOG.info('hitting %r', url)
    try:
        resp = requests.head(url, allow_redirects=False)
        return resp.status_code == 403 # forbidden.
    except (requests.ConnectionError, requests.Timeout):
        # couldn't connect for whatever reason
        return False

def reachable(url):
    "return True if given url can be hit."
    LOG.info('hitting %r', url)
    try:
        resp = requests.head(url, allow_redirects=False, timeout=0.25)
        return resp.status_code == 200
    except (requests.ConnectionError, requests.Timeout):
        # couldn't connect for whatever reason
        return False

#
# 
#

def branch(default='master'):
    """used in the `git.latest` state for the `branch` attribute.
    If a specific revision exists DONT USE THE BRANCH VALUE. 
    There will always be a branch value, even if it's the 'master' default"""
    if cfg('project.revision'):
        return 'pinned-revision' # arbitrary
    return cfg('project.branch', default)

def read_json(path):
    "reads the json from the given `path`, detecting base64 encoded versions."
    if os.path.exists(path):
        contents = open(path, 'r').read()
        if path.endswith('.b64'):
            # file is base64 encoded
            contents = base64.b64decode(contents)
        try:
            return json.loads(contents)
        except ValueError:
            # there is a bug where json is not properly escaped.
            LOG.error("failed to deserialize %r as json: %r", path, contents)

def project():
    "returns whatever project build data it can find."
    known_paths = ['/etc/build-vars.json.b64', '/etc/build_vars.json.b64']
    return first(filter(None, map(read_json, known_paths))) or {}

def project_name():
    "salt['elife.cfg']('project.project_name') works as well, but not on vagrant machines"
    return first(__grains__['id'].split('--'))

def cfn():
    "returns whatever cfn output data it can find."
    data = read_json("/etc/cfn-info.json") or {}
    if not data:
        # return early, don't bother deriving stuff from non-existant stuff
        return data
    
    derived_data = {}
    # add project hostname to cfn.derived.project_hostname
    # "parallel.ppp-dash.elifesciences.org"  (instance hostname)
    # => "ppp-dash.elifesciences.org"        (project hostname)
    hostname = lookup(data, 'outputs.DomainName', default=None)
    if hostname:
        project_hostname = '.'.join(hostname.split('.')[-3:])
        derived_data['project_hostname'] = project_hostname

    stackname = lookup(data, 'stack_name', default=None)
    if stackname:
        derived_data['is_prod_instance'] = stackname.split('-')[-1] in ['master', 'production']

    # is project (not instance) host reachable?
    if hostname and derived_data.get('is_prod_instance', False):
        key = url = derived_data['project_hostname'] # lax.elifesciences.org
        derived_data['project_hostname_reachable'] = once_a_day(key, partial(acme_enabled, url))
    
    data['derived'] = derived_data
    return data

def cfg(*paths):
    """returns the value at the given dot-delimited path within the project config.
    if just one path is specified, the default is None.
    if more than one path is specified, the value of the last path is the default.
    THIS MEANS IF YOU SPECIFY MORE THAN ONE PATH YOU MUST SPECIFY A DEFAULT"""
    default = paths[-1] if len(paths) > 1 else None    
    data = {
        'project': project(), # template 'compile' time data
        'cfn': cfn() # stack 'creation' time data
    }
    # don't raise exceptions if path value not found. very django-like
    return firstnn(map(lambda path: lookup(data, path, default=None), paths)) or default 

def b64encode(string):
    # used by the salt/elife-website/load-tester.sh:21
    # TODO: investigate using `base64` rather than code
    return base64.b64encode(string)
