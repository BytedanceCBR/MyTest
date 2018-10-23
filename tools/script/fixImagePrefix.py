#图片资源整理
#如果有带ex_前缀的图片， 删除对应的没有ex_前缀的图片， 然后将带ex_前缀图片重命名为不带ex_前缀图片

import os

needDelFileNames = []
needRenameFileNames = []

path = '/Users/zhangchenlong/Desktop/work/image'

for fileName in os.listdir(path):
    if fileName.find('ex_') == 0:
        noExFileName = fileName[3:len(fileName)]
        needDelFileNames.append(noExFileName)
        needRenameFileNames.append(fileName)

for fileName in needDelFileNames:
    if os.path.isfile(os.path.join(path,fileName)):
        os.remove(os.path.join(path,fileName))
        print 'rm > ' + fileName


for fileName in needRenameFileNames:
    if os.path.isfile(os.path.join(path, fileName)):
        newFileName = fileName[3:len(fileName)]
        os.renames(os.path.join(path, fileName), os.path.join(path, newFileName))
        print fileName + ' --> ' + newFileName

