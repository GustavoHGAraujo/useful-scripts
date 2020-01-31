#!/bin/bash

string=$1
if [ -z $string ]; then # if string is empty
	echo "Faltando fork e branch."
	exit 1
fi

array=(${string//:/ })

user=${array[0]}
branch=${array[1]}


# Check if there is changes in the current PR

modifiedFiles=$(git status | grep "modified" | wc -l)
newFiles=$(git status | grep "new file" | wc -l)
result=$(($modifiedFiles + $newFiles))

if [ $result -gt 0 ] # if result > 0
then
	echo "There are uncommitted changes. Aborting branch switching"
	exit
fi


# Killing app

appPackage="com.example"

if [ ! -z $appPackage ] # if appPackage is not empty
then
	adb shell am force-stop $package
	adb shell cmd package uninstall -k $package
fi


# Switching branches

possible_local_user=$(git remote -v | grep "$user" | cut -f1)
local_user=(${possible_local_user// / })

git remote update -p $local_user
git checkout "$local_user/$branch"
git submodule update

exit