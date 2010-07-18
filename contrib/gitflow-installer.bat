@echo off
sh %~dp0\gitflow-installer.sh %* || (
	echo You need to have at least git, e.g. msysgit, and unix tools, e.g. util-linux-ng, to be installed in your PATH."
	echo msysgit: http://code.google.com/p/msysgit/
	echo util-linux-ng: http://gnuwin32.sourceforge.net/packages/util-linux-ng.htm
)