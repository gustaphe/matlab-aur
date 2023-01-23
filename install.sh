#!/bin/sh
if ! stat -t matlab_*_glnxa64.zip >/dev/null 2>&1
then
    read -p"Download the Matlab for Linux zip file from the Mathworks website. Then press ENTER."
fi
unzip -X -K matlab_*_glnxa64.zip -d matlab
mv matlab/bin/glnxa64/libfreetype.so.6 \
   matlab/bin/glnxa64/libfreetype.so.6.MATLAB
echo "
* Log in with your Mathworks account.
* Accept the EULA.
* Select Advanced Options/I want to download without installing
* Choose a download location. Something temporary is best, as we will be moving the files. For instance /tmp/MATLAB. Remember what you type here, you will need it in the next step.
* Select Linux as your target system.
* Choose what products to install. Just installing MATLAB for now is easiest.
"
./matlab/install
read -p"Download directory (as entered in the installer) [/tmp/MATLAB]: " download_dir

if [ -z "$download_dir" ]; then
    download_dir="/tmp/MATLAB"
fi

rsync -a "$download_dir/" matlab
tar -cvf matlab.tar matlab

if [ ! -f "matlab.lic" ] || [ ! -f "matlab.fik" ]; then
    read -p"From the Mathworks website, copy license into matlab.lic as well as the file installation key into matlab.fik. When asked if the software is already installed, select \"no\" to get both key and license.
    Then press ENTER."
fi

read -p"Do you wish to edit PKGBUILD before installing (For instance if you are installing more products than just Matlab)? [y/N]" edit
if [ "$edit" == "y" ]; then
    echo "Edit PKGBUILD, then run makepkg -si."
    exit 0
fi
makepkg -si
