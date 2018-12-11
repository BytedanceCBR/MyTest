#! /bin/bash

echo "========will update========="

git submodule foreach git checkout feature/list_to_oc
git submodule foreach git pull origin feature/list_to_oc

echo "========update done========="

echo "=========will update pods========="
cd Article 
rm Podfile.lock
pod install --no-repo-update

cd ..

