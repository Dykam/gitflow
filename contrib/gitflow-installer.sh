#!/bin/sh

# git-flow make-less installer for *nix systems, by Rick Osborne
# Windows support added later by Dykam
# Based on the git-flow core Makefile:
# http://github.com/nvie/gitflow/blob/master/Makefile

# Licensed under the same restrictions as git-flow:
# http://github.com/nvie/gitflow/blob/develop/LICENSE

# Does this need to be smarter for each host OS?
type -P uname &>/dev/null || WINDOWS=true && DS="\\"
if [[ $(uname) == CYGWIN* || $(uname) == MINGW* ]] ; then # Windows
	WINDOWS=true
	DS="\\"
else
	DS="/"
fi

if [ -z "$INSTALL_PREFIX" ] ; then
	if [ $WINDOWS ] ; then
		INSTALL_PREFIX="$PROGRAMFILES\\GitFlow"
	else
		INSTALL_PREFIX="/usr/local/bin"
	fi
fi

if [ -z "$REPO_NAME" ] ; then
	REPO_NAME="gitflow"
fi

if [ -z "$REPO_HOME" ] ; then
	REPO_HOME="http://github.com/nvie/gitflow.git"
fi

EXEC_FILES="git-flow"
SCRIPT_FILES="git-flow-init git-flow-feature git-flow-hotfix git-flow-release git-flow-support git-flow-version gitflow-common gitflow-shFlags"
SUBMODULE_FILE="gitflow-shFlags"

echo "### gitflow no-make installer ###"

case "$1" in
	uninstall)
		echo "Uninstalling git-flow from $INSTALL_PREFIX"
		if [ -d "$INSTALL_PREFIX" ] ; then
			for script_file in $SCRIPT_FILES $EXEC_FILES ; do
				echo "rm -vf $INSTALL_PREFIX$DS$script_file"
				rm -vf "$INSTALL_PREFIX$DS$script_file"
			done
		else
			echo "The '$INSTALL_PREFIX' directory was not found."
			echo "Do you need to set INSTALL_PREFIX ?"
		fi
		exit
		;;
	help)
		echo "Usage: [environment] gitflow-installer.sh [install|uninstall]"
		echo "Environment:"
		echo "   INSTALL_PREFIX=$INSTALL_PREFIX"
		echo "   REPO_HOME=$REPO_HOME"
		echo "   REPO_NAME=$REPO_NAME"
		exit
		;;
	*)
		echo "Installing git-flow to $INSTALL_PREFIX"
		if [[ -d "$REPO_NAME" && -d "$REPO_NAME$DS.git" ]] ; then
			echo "Using existing repo: $REPO_NAME"
		else
			echo "Cloning repo from GitHub to $REPO_NAME"
			git clone "$REPO_HOME" "$REPO_NAME"
		fi
		if [ -f "$REPO_NAME$DS$SUBMODULE_FILE" ] ; then
			echo "Submodules look up to date"
		else
			echo "Updating submodules"
			lastcwd=$PWD
			cd "$REPO_NAME"
			git submodule init
			git submodule update
			cd "$lastcwd"
		fi
		if [ $WINDOWS ] ; then # Windows
			mkdir "$INSTALL_PREFIX"
			for exec_file in $EXEC_FILES ; do
				xcopy //Y "$REPO_NAME\\$exec_file" "$INSTALL_PREFIX"
				echo "@echo off" > "$INSTALL_PREFIX\\$exec_file.bat"
				echo "sh \"%~dp0$exec_file\"" >> "$INSTALL_PREFIX\\$exec_file.bat"
			done
			for script_file in $SCRIPT_FILES ; do
				xcopy //Y "$REPO_NAME\\$script_file" "$INSTALL_PREFIX"
				echo "@echo off" > "$INSTALL_PREFIX\\$script_file.bat"
				echo "sh \"%~dp0$script_file\"" >> "$INSTALL_PREFIX\\$script_file.bat"
			done
			# I've found no way of adding it persistently to the path
			echo "Add $INSTALL_PREFIX to the PATH for more convenient use"
		else
			install -v -d -m 0755 "$INSTALL_PREFIX"
			for exec_file in $EXEC_FILES ; do
				install -v -m 0755 "$REPO_NAME/$exec_file" "$INSTALL_PREFIX"
			done
			for script_file in $SCRIPT_FILES ; do
				install -v -m 0644 "$REPO_NAME/$script_file" "$INSTALL_PREFIX"
			done
		fi
		exit
		;;
esac
