#!/bin/bash

WORKSPACE="/Users/`whoami`/Desktop/he_project_build_tmp"

if [[ ! -d ${WORKSPACE} ]]; then
    mkdir -p ${WORKSPACE}
fi

DATE=$(date +%Y_%m_%d)
TIME=$(date +%H_%M_%S)


BUILD_FOLDER="${WORKSPACE}/${DATE}/${TIME}/build"
mkdir -p $BUILD_FOLDER

xcodebuild archive -workspace Article.xcworkspace \
-scheme "NewsInHouse" -configuration "Release" \
-DEBUG_INFORMATION_FORMAT='dwarf-with-dsym' \
-archivePath ${BUILD_FOLDER}/iOS.xcarchive

EXPORT_PATH="${BUILD_FOLDER}/NewsInHouse_${DATE}_${TIME}"

if [[ $? -eq 0 ]]; then
    xcodebuild -exportArchive -archivePath "${BUILD_FOLDER}/iOS.xcarchive" -exportPath ${EXPORT_PATH} -exportOptionsPlist ${WORKSPACE}/exportOption.plist    
fi

if [[ $? -eq 0 ]]; then
    cp "${EXPORT_PATH}/NewsInHouse.ipa" "/usr/local/var/www/"
    echo $(date '+%Y-%m-%d %H:%M:%S') > "/usr/local/var/www/latest_time.txt"
fi

