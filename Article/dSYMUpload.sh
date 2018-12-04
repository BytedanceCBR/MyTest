#!/bin/sh
#
################################################################################
# 注意: 请配置下面的信息
################################################################################
HMD_APP_ID="1370"
HMD_APP_KEY="APM"
DSYM_UPLOAD_URL="http://symbolicate.byted.org/slardar_ios_upload"

################################################################################
# 自定义配置
###############################################################################
# Debug模式编译是否上传，1＝上传 0＝不上传，默认不上传
UPLOAD_DEBUG_SYMBOLS=0

# 模拟器编译是否上传，1＝上传，0＝不上传，默认不上传
UPLOAD_SIMULATOR_SYMBOLS=0

#
# # 脚本默认配置的版本格式为CFBundleShortVersionString(CFBundleVersion),  如果你修改默认的版本格式, 请设置此变量, 如果不想修改, 请忽略此设置
# CUSTOMIZED_APP_VERSION=""

################################################################################
# 注意: 如果你不知道此脚本的执行流程和用法，请不要随便修改！
################################################################################
function main() {
    # 退出执行并打印提示信息
    warningWithMessage() {
        echo "--------------------------------"
        echo -e "${1}"
        echo "--------------------------------"
        echo "No upload and over."
        echo "----------------------------------------------------------------"
        UPLOADFLAG=0
    }
    
    UPLOADFLAG=1
    
    echo "Uploading dSYM to 客户端基础技术APM平台."
    echo ""
    
    # 读取Info.plist文件中的版本信息
    echo "Info.Plist : ${INFOPLIST_FILE}"
    
    BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' "${INFOPLIST_FILE}")
    BUNDLE_SHORT_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "${INFOPLIST_FILE}")
    
    # 组装识别的版本信息(格式为CFBundleShortVersionString(CFBundleVersion), 例如: 1.0(1))
    if [ ! "${CUSTOMIZED_APP_VERSION}" ]; then
    HMD_APP_VERSION="${BUNDLE_SHORT_VERSION}(${BUNDLE_VERSION})"
    else
    HMD_APP_VERSION="${CUSTOMIZED_APP_VERSION}"
    fi
    
    echo "--------------------------------"
    echo "Step 1: Prepare application information."
    echo "--------------------------------"
    
    echo "Product Name: ${PRODUCT_NAME}"
    echo "Bundle Identifier: ${PRODUCT_BUNDLE_IDENTIFIER}"
    echo "Version: ${BUNDLE_SHORT_VERSION}"
    echo "Build: ${BUNDLE_VERSION}"
    
    echo "HMD App ID: ${HMD_APP_ID}"
    echo "HMD App key: ${HMD_APP_KEY}"
    echo "HMD App Version: ${HMD_APP_VERSION}"
    
    echo "--------------------------------"
    echo "Step 2: Check the arguments ..."
    echo "--------------------------------"
    
    ##检查模拟器是否允许上传符号
    if [ "$EFFECTIVE_PLATFORM_NAME" == "-iphonesimulator" ]; then
    if [[ $UPLOAD_SIMULATOR_SYMBOLS -eq 0 ]]; then
    warningWithMessage "Warning: Build for simulator and skipping to upload. \nYou can modify 'UPLOAD_SIMULATOR_SYMBOLS' to 1 in the script." 0
    fi
    fi
    
    # 检查DEBUG模式是否允许上传符号
    if [ "${CONFIGURATION=}" == "Debug" ]; then
    if [[ $UPLOAD_DEBUG_SYMBOLS -eq 0 ]]; then
    warningWithMessage "Warning: Build for debug mode and skipping to upload. \nYou can modify 'UPLOAD_DEBUG_SYMBOLS' to 1 in the script." 0
    fi
    fi
    
    # 检查必须参数是否设置
    if [ ! "${HMD_APP_ID}" ]; then
    warningWithMessage "Error: HMD App ID not defined." 1
    fi
    
    if [ ! "${HMD_APP_KEY}" ]; then
    warningWithMessage "Error: HMD App Key not defined." 1
    fi
    
    CFBundleIdentifier=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "${INFOPLIST_FILE}")
    
    if [ ! "${PRODUCT_BUNDLE_IDENTIFIER}" ]; then
    PRODUCT_BUNDLE_IDENTIFIER=${CFBundleIdentifier}
    echo "WARNING!: Bundle Identifier not defined. Use CFBundleIdentifier"
    if [ ! "${CFBundleIdentifier}" ]; then
    warningWithMessage "Error!:  Bundle Identifier not defined. CFBundleIdentifier not defined" 1
    fi
    fi
    
    function uploadDSYM() {
        DSYM_SRC="$1"
        if [ ! -d "$DSYM_SRC" ]; then
        warningWithMessage "dSYM source not found: ${DSYM_SRC}" 1
        fi
        
        APPID="${HMD_APP_ID}"
        VERSION="${HMD_APP_VERSION}"
        BID="${PRODUCT_BUNDLE_IDENTIFIER}"
        
        # 清理
        $(find ${BUILT_PRODUCTS_DIR} -name "*.zip" -mindepth 1 -delete)
        FILENAME=$(basename ${DSYM_SRC})
        DSYM_SYMBOL_OUT_ZIP_NAME="${VERSION}.zip"
        DSYM_ZIP_FPATH="${BUILT_PRODUCTS_DIR}/${DSYM_SYMBOL_OUT_ZIP_NAME}"
        cd "${BUILT_PRODUCTS_DIR}"
        echo "build products dir is: ${BUILT_PRODUCTS_DIR}"
        echo "DSYM_ZIP_FPATH is: ${DSYM_ZIP_FPATH}"
        PAD=$(zip -r ${DSYM_SYMBOL_OUT_ZIP_NAME} ${FILENAME})
        
        if [ ! -e "${DSYM_ZIP_FPATH}" ]; then
        warningWithMessage "no dSYM zip archive generated: ${DSYM_ZIP_FPATH}" 1
        fi
        
        FILESIZE=$(/usr/bin/stat -f%z ${DSYM_ZIP_FPATH})
        echo "dsym size: ${FILESIZE}"
        # if [ $FILESIZE -ge 52428800 ] ; then
        #     echo "dSYM zipped file is too big, please upload mannually."
        #     echo "dSYM zipped file path: ${DSYM_ZIP_FPATH}"
        #     echo "-----------------------------------------------------------------"
        #     return
        # fi
        
        echo "--------------------------------"
        echo "Step 3: Upload the zipped dSYM file."
        echo "--------------------------------"
        MD5ZIP=$(md5 -q ${DSYM_ZIP_FPATH})
        if [ ! ${#MD5ZIP} -eq 32 ]; then
            warningWithMessage "Error: Failed to caculate md5 of zipped file." 1
            fi
            echo "zip md5 : ${MD5ZIP}"
            echo "signature : ${MD5ZIP}"
            
            echo "dSYM upload domain: ${DSYM_UPLOAD_DOMAIN}"
            
            echo "dSYM upload url: ${DSYM_UPLOAD_URL}"
            
            # Upload dSYM to HMD
            echo "curl ${DSYM_UPLOAD_URL} -F \"file=@${DSYM_ZIP_FPATH}\" -H \"Content-Type: multipart/form-data\" -w %{http_code} -v "
            
            echo "--------------------------------"
            
            # 上传请求
            STATUS=$(curl ${DSYM_UPLOAD_URL} -F "file=@${DSYM_ZIP_FPATH}" -H "Content-Type: multipart/form-data" -w %{http_code} -v)
            
            UPLOAD_RESULT="FAILTURE"
            echo "HMD server response: ${STATUS}"
            
        }
        
        # .dSYM文件信息
        echo "DSYM FOLDER ${DWARF_DSYM_FOLDER_PATH}"
        
        DSYM_FOLDER="${DWARF_DSYM_FOLDER_PATH}"
        
        IFS=$'\n'
        
        for dsymFile in $(find "$DSYM_FOLDER" -name "${PRODUCT_NAME}.*.dSYM"); do
        echo "Found dSYM file: $dsymFile"
        if [ ${UPLOADFLAG} -eq 1 ]; then
        uploadDSYM $dsymFile
        fi
        done
    }
    
    if [[ -z $uploaddsym ]]; then
    main
    fi
