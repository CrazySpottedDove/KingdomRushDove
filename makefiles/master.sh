#!/bin/bash

branch_name=$(cat makefiles/.branch)
git push origin $branch_name
git checkout master
git merge $branch_name
