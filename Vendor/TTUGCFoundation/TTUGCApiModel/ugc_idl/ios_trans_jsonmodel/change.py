# coding:UTF-8 #

import os

def changeExt():
    for file in os.listdir(os.getcwd()):
        if file.endswith(".idl"):
            print file
            fh = open(file,"r")
            st = 'import "enum.proto";\n' \
                 'import "common.proto";\n'
            for line in fh.readlines():
                st += removeSemicolon(line)
            fhw = open(file.replace(".idl",".proto"), "w")
            fhw.writelines(st)
            fh.close()
            fhw.close()

def removeSemicolon(st):
        return st

changeExt();
