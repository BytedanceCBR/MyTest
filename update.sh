#! /bin/bash

echo "========will update========="

git submodule foreach git checkout feauture/develop
git submodule foreach git pull origin feature/develop

echo "========update done========="

echo "=========will update pods========="
cd Article 
rm Podfile.lock
pod install --no-repo-update

cd ..

