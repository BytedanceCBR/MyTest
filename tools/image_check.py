#! /usr/bin/python3

import os.path
from stat import *
import sys 

def check(dir):
    # walk dir
    dirs = []
    imgs = []
    dirs.append(dir)
    excepts = ['DerivedData','Deleted','SSTestFlight','tools','TTDebugAssistant','Example']

    while len(dirs) > 0:
        d = dirs[0]
        sub_files = os.listdir(d)        
        for f in sub_files:   
            if  f in excepts:
                continue

            if f.startswith("."):
                continue

            abs_path = os.path.join(d,f)
            if os.path.isdir(abs_path):
                dirs.append(abs_path)                
            elif abs_path.endswith('.png') or abs_path.endswith('.jpg'):
                imgs.append(abs_path)                
        dirs.remove(d)

    print("======CHECK IMAGE SIZE =======")
    for img in imgs:        
        st = os.stat(img)
        size = st[ST_SIZE]
        if size > 100*1000:
            print("image: %s size is: %d"%(img,size))

    print("======CHECK IMAGE DONE =======")            

if __name__ == '__main__':

    dir = sys.argv[1]
    if dir is None:
        print("USAGE: %s directory"%(sys.argv[0]))
        exit(0)

    check(dir)    