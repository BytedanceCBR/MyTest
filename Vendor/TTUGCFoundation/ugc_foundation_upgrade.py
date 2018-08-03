#!/usr/bin/env python3

import sys
import subprocess
import os, errno
import shutil
import re

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class cd:
    """Context manager for changing the current working directory"""
    def __init__(self, newPath):
        self.newPath = os.path.expanduser(newPath)

    def __enter__(self):
        self.savedPath = os.getcwd()
        os.chdir(self.newPath)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.savedPath)

def find_dir(name, path):
    for root, dirs, files in os.walk(path):
        if name in dirs:
            return os.path.join(root, name)

def exit_err(error):
	print(bcolors.FAIL + error + bcolors.ENDC)
	exit(); 

def upgrade_version(matched):
    version_str = matched.group() # s.version          = '0.1.6'
    m = re.search("[0-9].+[0-9]", version_str)
    version = m.group() # 0.1.6
    start_index = version.rfind(".", 0, len(version))
    int_value_str = version[start_index + 1 : len(version_str) - 1]
    int_value = int(int_value_str) + 1
    version = version[0: start_index + 1] + str(int_value)
    return version

# git clone最新pod
with cd('../'):
	pod_path = find_dir('git_TTUGCFoundation', os.getcwd())
if not pod_path:
	with cd('../'):
		subprocess.call(['git', 'clone', 'git@code.byted.org:TTIOS/TTUGCFoundation.git', 'git_TTUGCFoundation'])
	pod_path = find_dir('git_TTUGCFoundation', '..')
	if not pod_path:
		exit_err("unable to clone git@code.byted.org:TTIOS/TTUGCFoundation.git")

print(bcolors.OKBLUE + 'pod_path: ' + pod_path + bcolors.ENDC)

# 更新当前pod
subprocess.call(['git', 'reset', '--hard'], cwd=pod_path)
subprocess.call(['git', 'pull'], cwd=pod_path)


# 先升级podspec
# modify Podspec, Read in the file
with open(pod_path + '/TTUGCFoundation.podspec', 'r') as file :
  filedata = file.read()
# Replace the target string
str_to_replace = "s.version          = '.+'"
version = upgrade_version(re.search(str_to_replace, filedata))

with open(os.getcwd() + '/TTUGCFoundation.podspec', 'r') as file :
  currentfiledata = file.read()
replaced = re.sub(str_to_replace, "s.version          = '" + version + "'", currentfiledata, flags = re.M)
# Write the file out again
with open(pod_path + '/TTUGCFoundation.podspec', 'w') as file:
  file.write(replaced)


# 替换新代码 
# remove and copy
subprocess.call(['rm', '-rf', './Example/Pods'], cwd=os.getcwd())
for dir, subdirs, files in os.walk(pod_path): 
    for subdir in subdirs:
        if subdir.startswith('.'):
            continue
        print(bcolors.OKBLUE + subdir)
        shutil.rmtree(pod_path + "/" + subdir)
    break

for dir, subdirs, files in os.walk(os.getcwd()): 
    for subdir in subdirs:
        if subdir.startswith('.'):
            continue
        shutil.copytree(os.getcwd() + "/" + subdir, pod_path + "/" + subdir)
    break
# commit
subprocess.call(['git', 'add', '.'], cwd=pod_path)
subprocess.call(['git', 'commit', '-a', '-m', 'upgrade TTUGCFoundation to ' + version], cwd=pod_path)
subprocess.call(['git', 'push'], cwd=pod_path)
# push
subprocess.call(['git', 'tag', version], cwd=pod_path)
subprocess.call(['git', 'push', 'origin', version], cwd=pod_path)
print(bcolors.OKGREEN + '新增tag:' + version + bcolors.ENDC)


# 更新podspec
# 先更新podspec repo
pods_repo_path = os.path.expanduser('~') + '/.cocoapods/repos/byted-tt_pods_specs/TTUGCFoundation'
subprocess.call(['git', 'reset', '--hard'], cwd=pods_repo_path)
subprocess.call(['git', 'pull'], cwd=pods_repo_path)
# 新建版本
subprocess.call(['mkdir', version], cwd=pods_repo_path)
subprocess.call(['cp', pod_path + '/TTUGCFoundation.podspec', pods_repo_path + '/'+ version + '/'], cwd=pod_path)
pods_repo_path = pods_repo_path + '/' + version
# push
subprocess.call(['git', 'add', '.'], cwd=pods_repo_path)
subprocess.call(['git', 'commit', '-a', '-m', '[Update] TTUGCFoundation ('+ version + ')'], cwd=pods_repo_path)
subprocess.call(['git', 'push'], cwd=pods_repo_path)

shutil.rmtree(pod_path)

print(bcolors.OKGREEN + 'finish!' + bcolors.ENDC)