#!/bin/bash

branch_name=$(cat .branch)
git pull origin master
git checkout $branch_name
git merge master