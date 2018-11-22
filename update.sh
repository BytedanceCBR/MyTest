#! /bin/bash

echo "========will update========="

git submodule foreach git checkout feauture/develop
git submodule foreach git pull origin feature/develop

echo "========update done========="

