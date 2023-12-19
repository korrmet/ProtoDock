#! /bin/sh

mode=
packages=
name=
nozip=

for key in $@
do
  if [[ $key = "--build" ]]
  then
    mode="build"
    break
  elif [[ $key = "--run" ]]
  then
    mode="run"
    break
  elif [[ $key = "--help" ]]
  then
    echo "Build mode:"
    echo "Usage: protodock.sh --build --name <name of the container> [options] <list>"
    echo "Options: --nozip prevent to pack container"
    echo ""
    echo "Run mode:"
    echo "Usage: protodock.sh --run <path to container> <mount folders>"
    exit 0
  fi
done

if [[ $mode = "build" ]]
then
  __name_key=
  for key in $@
  do
    if [[ $key = "--help" ]]
    then
      continue
    elif [[ $key = "--name" ]]
    then
      __name_key=1
      continue
    elif [[ $key = "--nozip" ]]
    then
      nozip=1
    elif [[ $key = "--build" ]]
    then
      continue
    elif [[ $key = "--run" ]]
    then
      continue
    else
      if [[ $__name_key = 1 ]]
      then
        name=$key
        __name_key=""
      else
        packages="$packages $key"
      fi
    fi
  done
  
  if [[ $name = "" ]]
  then
    echo "Specify name. Use "--help" key to get help."
    exit 0
  fi
  
  echo "$name ($nozip) <= $packages"
  
  eval "mkdir $name"
  eval "pacstrap -N $name $packages"
  
  if [[ $nozip = 1 ]]
  then
    exit 0
  fi
  
  eval "sudo rm -rf $name/var/cache"
  eval "tar vcfJ $name.tar.xz -C $name ."
  eval "sudo rm -rf $name"
  exit 0

elif [[ $mode = "run" ]]
then
  if [[ $# < 2 ]]
  then
    echo "Invalid arguments. Use "--help" key to get help."
    exit 0
  fi

  contpath=$2
  contname=$(eval "basename $contpath")

  echo "unpacking $contname"
  eval "rm -rf /tmp/protodock/$contname"
  eval "mkdir -p /tmp/protodock/$contname"
  eval "tar -vxf $contpath --directory /tmp/protodock/$contname"
  eval "sudo mount -t proc none /tmp/protodock/$contname/proc"
  eval "sudo mount -t sysfs none /tmp/protodock/$contname/sys"
  eval "sudo mount -o bind /dev /tmp/protodock/$contname/dev"

  for mountdir in ${@:3}
  do
    echo "mounting $mountdir"
    mountname=$(eval "basename $mountdir")
    eval "mkdir /tmp/protodock/$contname/$mountname"
    eval "sudo mount -o bind $mountdir /tmp/protodock/$contname/$mountname"
  done

  eval "sudo chroot /tmp/protodock/$contname /bin/bash"
  
  eval "sudo umount /tmp/protodock/$contname/proc"
  eval "sudo umount /tmp/protodock/$contname/sys"
  eval "sudo umount /tmp/protodock/$contname/dev"
  
  for mountdir in ${@:3}
  do
    echo "unmounting $mountdir"
    mountname=$(eval "basename $mountdir")
    eval "sudo umount /tmp/protodock/$contname/$mountname"
  done

  eval "sudo rm -rf /tmp/protodock/$contname"
  echo "welcome home"

  exit 0

else
  echo "Specify mode. Use "--help" key to get help."
  exit 0
fi

exit 0
