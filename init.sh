#!/bin/bash

system=$(uname -s)
machine=$(uname -m)

# Fix virtual system on windows
for s in Windows CYGWIN MINGW MSYS UWIN; do
	if [[ "$system" == "$s"* ]]; then
		system=Windows
		break
	fi
done

echo "System is $system:$machine"



### Fetch necessary DLLs on Windows
if [[ "$system" == "Windows" ]]; then
	mkdir -p "bin/"

	# Qt directory
	qtdir=""
	echo "Submit your local Qt ($machine) directory and press ENTER:"
	read -e qtdir

	while [[ ! -d "$qtdir" ]]; do
		echo "'$qtdir' is not a directory. (Ex: 'C:/Qt/5.8.0/msvc2015..'). Please verify your Qt path and resubmit:"
		read -e qtdir
	done

	for module in "bin/Qt5Core" "bin/Qt5Gui" "bin/Qt5Network" "bin/Qt5WebSockets" "bin/Qt5Widgets" "plugins/platforms/qwindows"; do
		for suffix in "" "d"; do
			while [[ ! -f "$qtdir/$module$suffix.dll" ]]; do
				echo "'$qtdir/$module$suffix.dll' could not be located. Please verify your Qt path and resubmit:"
				read -e qtdir
			done
			cp "$qtdir/$module$suffix.dll" "bin/"
		done
	done

	echo -n $qtdir >".qtdir"
	
	# OpenSSL directory
	ssldir=""
	echo "Submit your local OpenSSL ($machine) directory and press ENTER:"
	read -e ssldir

	while [[ ! -d "$ssldir" ]]; do
		echo "'$ssldir' is not a directory. (Ex: 'C:/Program Files/OpenSSL'). Please verify your SSL path and resubmit:"
		read -e ssldir
	done

	for module in "libeay32" "ssleay32"; do
		while [[ ! -f "$ssldir/$module.dll" ]]; do
			echo "'$ssldir/$module.dll' could not be located. Please verify your SSL path and resubmit:"
			read -e ssldir
		done
		cp "$ssldir/$module.dll" "bin/"
	done
fi



### Get premake binary
version=5.0.0-alpha13
location=.
download_base=https://github.com/premake/premake-core/releases/download/v$version/premake-$version

# Windows
if [[ "$system" == "Windows" ]]; then
	file=$location/premake5.zip
	curl -L -o $file $download_base-windows.zip
	unzip -oqu $file -d $location/
	rm -f $file

# Linux x86*
elif [[ "$system" == "Linux" && "$machine" == "x86"* ]]; then
	file=$location/premake5.tar.gz
	curl -L -o $file $download_base-linux.tar.gz
	tar -xvzf $file -C $location/
	rm -f $file

# macOS
elif [[ "$system" == "Darwin" ]]; then
	file=$location/premake5.tar.gz
	curl -L -o $file $download_base-macosx.tar.gz
	tar -xvzf $file -C $location/
	rm -f $file

# Prebuilt binaries not available. Build from source.
else
	file=$location/premake5-src.zip
	curl -L -o $file $download_base-src.zip
	unzip -o $file -d $location/
	echo "Premake binaries unavailable for $system:$machine. Building from source.."
	make -f $location/Bootstrap.mak $system
	cp $location/bin/release/premake5 $location/
	rm -rf $location/premake-$version/
	rm -f $file
fi



### Initialize submodules
git submodule update --init
git submodule foreach --recursive "git submodule update --init"
