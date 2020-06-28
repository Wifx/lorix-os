# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

def print_info(layer, rel, inc_dirty, d):
    rev_hash = get_rel_path_rev(layer, rel, inc_dirty, d)
    rev_date = get_rel_path_rev_date(layer, rel, d)
    bb.note("Workspace revision hash: " + rev_hash)
    bb.note("Workspace revision date: " + rev_date)

def get_rev(path, inc_dirty):
    import subprocess
    cmd = 'git log -n1 --format=format:%h '
    rev = subprocess.Popen('cd ' + path + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True).communicate()[0]
    if sys.version_info.major >= 3 :
        rev = rev.decode()
    if inc_dirty == True and get_rev_dirty(path):
        rev += ".dirty"
    return rev

def get_rev_date(path):
    import subprocess
    cmd = 'TZ=UTC git show --quiet --date="format-local:%Y-%m-%dT%H:%M:%SZ" --format=format:%cd '
    rev = subprocess.Popen('cd ' + path + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True).communicate()[0]
    if sys.version_info.major >= 3 :
        rev = rev.decode()
    return rev

def get_rev_dirty(path):
    import subprocess
    cmd = 'git diff-index --quiet HEAD -- '
    rev = subprocess.Popen('cd ' + path + ' ; ' + cmd, stdout=subprocess.PIPE, shell=True)
    rev.communicate()
    if sys.version_info.major >= 3 :
        rev = rev.returncode
    return rev

def get_rel_path_rev(layer, rel, inc_dirty, d):
    targetrev = "unknown"
    targetpath = get_rel_path(layer, rel, d)
    targetrev = get_rev(targetpath, inc_dirty)
    return targetrev

def get_rel_path_rev_date(layer, rel, d):
    targetrevdate = "unknown"
    targetpath = get_rel_path(layer, rel, d)
    targetrevdate = get_rev_date(targetpath)
    return targetrevdate

def get_rel_path_rev_dirty(layer, rel, d):
    targetdirty = 0
    targetpath = get_rel_path(layer, rel, d)
    targetdirty = get_rev_dirty(targetpath)
    return targetdirty

def get_rel_path(layer, rel, d):
    bblayers = d.getVar("BBLAYERS", True)
    layerpath = filter(lambda x: x.endswith(layer), bblayers.split())
    if sys.version_info.major >= 3 :
         layerpath = list(layerpath)
    return os.path.join(layerpath[0], rel)

def source_shell_param_file(path, d):
    import re
    reg = re.compile('(?P<name>\w+)(\="(?P<value>.+)")*')
    for line in open(path, 'r'):
        m = reg.match(line)
        if m:
            name = m.group('name')
            value = ''
            if m.group('value'):
                value = m.group('value')
                d.setVar(name, value)
