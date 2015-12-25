#!/bin/bash

ROOT=$(pwd)

# install lau
cd ${ROOT}
sudo apt-get install -y libreadline-dev
curl -R -O http://www.lua.org/ftp/lua-5.3.1.tar.gz
tar zxf lua-5.3.1.tar.gz
cd lua-5.3.1
make linux test
sudo make install

# install luarocks
cd ${ROOT}
sudo apt-get install -y unzip
wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz
tar zxpf luarocks-2.2.2.tar.gz
cd luarocks-2.2.2
./configure
sudo make bootstrap

# install luasocket
cd ${ROOT}
sudo luarocks install luasocket

# install luaevent
cd ${ROOT}
sudo apt-get install -y libevent-dev
sudo apt-get install -y git
git clone https://github.com/hugolu/luaevent
cd luaevent
make install

# install luafilesystem
cd ${ROOT}
sudo luarocks install luafilesystem

# install luaposix
cd ${ROOT}
sudo luarocks install luaposix

# install inotify-tools
cd ${ROOT}
sudo apt-get install -y inotify-tools

# install my utils
cd ${ROOT}
sudo cp -f utils.lua /usr/local/share/lua/5.3/
