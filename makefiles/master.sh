#!/bin/bash

branch_name=$(cat .branch)
git push origin $branch_name
git checkout master
git merge $branch_name
