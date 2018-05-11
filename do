#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.

function help_output {
  echo "Possible commands:"
  echo "  $0 <folder> COMMAND"
  echo ""
  echo "    COMMAND:"
  echo "        workspace     TODO"
  echo "        release:      TODO"
  echo "        debug:        TODO"
  echo "        force-master: TODO"
}  

function main {
  if [ $1 = "-h" ] || [ $1 = "--help" ] || [ $# -lt "2" ]; then
    help_output
  else
    local folder=$1; shift
    local cmd=$1; shift
    if [ $cmd = "workspace" ] && [ ! -d "$folder" ]; then
      git clone git@github.com:woelke/workspace.git $folder
      $folder/set_build vast core
    fi
    cd $folder
    cmd_dispatch $cmd $target
  fi
}

function cmd_dispatch {
  local cmd=$1; shift
  do_caf $cmd
  do_vast $cmd
  do_core $cmd
}

function create_makefile {
  local folder=$1
  cat <<EOF >> ${folder}/Makefile
MAIN = build

all:
	ninja -C \$(MAIN)

clean:
	ninja -C \$(MAIN) clean

install:
	ninja -C \$(MAIN) install 
EOF
}

function force_master {
  git fetch --all
  git reset --hard origin/master
  git checkout master
  git pull
  git clean --force --quiet -d
}

function do_caf {
  local cmd=$1
  local folder=caf
  echo "##-- $folder $cmd --##"
  if [ "$cmd" = "workspace" ]; then
    if [ ! -d "$folder" ]; then
      git clone git@github.com:actor-framework/actor-framework.git $folder
    fi
    create_makefile $folder
    return 
  fi
  cd $folder
  if [ "$cmd" = "release" ]; then
    CXX=/usr/local/opt/llvm/bin/clang++ LDFLAGS=$(/usr/local/opt/llvm/bin/llvm-config --ldflags) ./configure --generator=Ninja --no-opencl --no-openssl --no-python --build-type=release 
    make
  elif [ "$cmd" = "debug" ]; then
    CXX=/usr/local/opt/llvm/bin/clang++ LDFLAGS=$(/usr/local/opt/llvm/bin/llvm-config --ldflags) ./configure --generator=Ninja --no-opencl --no-openssl --no-python --build-type=debug --with-runtime-checks --with-address-sanitizer #--with-log-level=TRACE 
    make
  elif [ "$cmd" = "force-master" ]; then
    force_master
  else
    echo "Error! In target caf, unkown command: $cmd"
    help_output
  fi 
  cd ..
}

function do_vast {
  local cmd=$1
  local folder=vast
  echo "##-- $folder $cmd --##"
  if [ "$cmd" = "workspace" ]; then
    if [ ! -d "$folder" ]; then
     git clone git@github.com:vast-io/vast.git $folder
    fi
    create_makefile $folder
    return 
  fi
  cd $folder
  if [ "$cmd" = "release" ]; then
    CXX=/usr/local/opt/llvm/bin/clang++ LDFLAGS=$(/usr/local/opt/llvm/bin/llvm-config --ldflags) ./configure --with-caf=../caf/build/ --generator=Ninja --with-doxygen=/usr/local/bin/doxygen --build-type=release
    make
  elif [ "$cmd" = "debug" ]; then
    CXX=/usr/local/opt/llvm/bin/clang++ LDFLAGS=$(/usr/local/opt/llvm/bin/llvm-config --ldflags) ./configure --with-caf=../caf/build/ --generator=Ninja --with-doxygen=/usr/local/bin/doxygen --build-type=debug --enable-asan
    make
  elif [ "$cmd" = "force-master" ]; then
    force_master
  else
    echo "Error! In target vast, unkown command: $cmd"
    help_output
  fi 
  cd ..
}

function do_core {
  local cmd=$1
  local folder=core
  echo "##-- $folder $cmd --##"
  if [ "$cmd" = "workspace" ]; then
    if [ ! -d "$folder" ]; then
      git clone git@github.com:tenzir/core.git $folder
    fi
    create_makefile $folder
    return 
  fi
  cd $folder
  if [ "$cmd" = "release" ]; then
    CXX=/usr/local/opt/llvm/bin/clang++ LDFLAGS=$(/usr/local/opt/llvm/bin/llvm-config --ldflags) ./configure --with-vast=../vast/build  --with-caf=../caf/build/ --generator=Ninja --build-type=release
    make
  elif [ "$cmd" = "debug" ]; then
    CXX=/usr/local/opt/llvm/bin/clang++ LDFLAGS=$(/usr/local/opt/llvm/bin/llvm-config --ldflags) ./configure --with-vast=../vast/build  --with-caf=../caf/build/ --generator=Ninja --build-type=debug --enable-asan
    make
  elif [ "$cmd" = "force-master" ]; then
    force_master
  else
    echo "Error! In target core, unkown command: $cmd"
    help_output
  fi 
  cd ..
}

main $@
