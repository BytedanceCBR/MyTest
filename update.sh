#! /bin/bash

echo "========will update========="

git submodule foreach git checkout feature/develop
git submodule foreach git pull origin feature/develop

echo "========update done========="
