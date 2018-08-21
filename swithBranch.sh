#! /ban/bash

#参数解释:
#branchName:需要切换到得分支

#e.g. sh swithBranch.sh zone1.0

branchName=$1

branch=origin/${branchName}

git checkout --track $branch

if [ $? -ne 0 ]; then
    echo "checkout track branch false"
    
    git checkout $branchName
    
    if [ $? -ne 0 ]; then
       echo "checkout branch false"
    else
       echo "checkout branch sucess"
    fi

else
    echo "checkout track branch success"
fi
