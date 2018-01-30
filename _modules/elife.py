import os, json
import base64
import subprocess

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

#
# 
#

def rev(default_branch='master'):
    """used in the `git.latest` state for the `rev` attribute.
    Prefer a commit if specified in revision, otherwise a branch name
    and when there's nothing specified default to master"""
    return cfg('project.revision', 'project.branch', default_branch)

def branch(default='master'):
    """used in the `git.latest` state for the `branch` attribute.
    If a specific revision exists DON'T USE THE BRANCH VALUE. 
    There will always be a branch value, even if it's the 'master' default"""
    if cfg('project.revision'):
        return '' # results in a None value for git.latest
    return cfg('project.branch', default)

def image_tag():
    """used to deploy a particular tag of a Docker image.
    
    May return:
    - a commit
    - a branch name such as `approved`
    - the conventional `latest`"""
    revision = cfg('project.revision')
    if revision == 'master':
        return 'latest' # conventionally stable Docker tag
    if not revision:
        return 'latest' # conventionally stable Docker tag
    return revision

def image_label(image, label, image_tag='latest'):
    """used to retrieve a `label` from an `image`. 
    
    Optionally specify an `image_tag` to pin.

    Warning: it will pull the image first, using bandwidth, time and disk space."""

    return subprocess.check_output("/usr/local/docker-scripts/docker-read-label", "%s:%s" % (image, image_tag), label)

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

def project_name():
    "salt['elife.cfg']('project.project_name') works as well, but not on vagrant machines"
    return first(__grains__['id'].split('--'))

def cfn():
    "returns whatever cfn output data it can find."
    return read_json("/etc/cfn-info.json") or {}

def cfg(*paths):
    """returns the value at the given dot-delimited path within the project config.
    if just one path is specified, the default is None.
    if more than one path is specified, the value of the last path is the default.
    THIS MEANS IF YOU SPECIFY MORE THAN ONE PATH YOU MUST SPECIFY A DEFAULT"""
    default = paths[-1] if len(paths) > 1 else None    
    paths = paths[:-1] if len(paths) > 1 else paths
    data = {
        'project': read_json('/etc/build-vars.json.b64') or {}, # template 'compile' time data
        'cfn': cfn() # stack 'creation' time data
    }
    # don't raise exceptions if path value not found. very django-like
    return firstnn(map(lambda path: lookup(data, path, default=None), paths)) or default 

def b64encode(string):
    # used by the salt/elife-website/load-tester.sh:21
    # TODO: investigate using `base64` rather than code
    return base64.b64encode(string)

def only_on_aws():
    LOG.info('cfn is %s', cfn())
    return cfn() != {}
