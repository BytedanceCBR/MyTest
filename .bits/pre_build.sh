#!/bin/bash

# 打印每句话的log
#set -x

echo 'zjing pre build'
# 打印环境变量
printenv

echo 'zjing printenv end'

#iOS编译前置脚本
echo "pre_build IS_MONKEY_TASK="$IS_MONKEY_TASK
if [[ "${IS_MONKEY_TASK}" == "true" ]]; then
    echo "pre_build monkey task, open auto login"
    sed -i '' 's/\/\/#define/#define/g' ${WORKSPACE}/Article/Monkey/FHMonkeyConfigManager.m
fi
echo "pre_build open auto login done"
