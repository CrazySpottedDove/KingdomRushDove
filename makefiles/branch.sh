#!/bin/bash

branch_name=$(cat makefiles/.branch)
git pull origin master
git checkout $branch_name
git merge master