#! /bin/sh

if [[ $# < 1 ]]
then
  echo Too few arguments
  exit 0
fi

__jail=$1
eval "rm -r $__jail"

for __file in ${@:2}
do
  __realfile=$(eval "which $__file")
  __jailfile=$__jail$__realfile
  eval "mkdir -p $(eval "dirname $__jailfile")"
  eval "cp $__realfile $__jailfile"
  
  __prev=
  __curr=
  __next=
  for __iter in $(eval "ldd $__realfile")
  do
    __prev=$__curr
    __curr=$__next
    __next=$__iter
    
    if [[ "$__curr" = "=>" ]]
    then
      __libname=$(eval "basename $__prev")
      __libpath=$(eval "dirname $__next")
      eval "mkdir -p $__jail$__libpath"
      eval "cp $__libpath/$__libname $__jail$__libpath/$__libname"
    fi
  done
done

eval "mv $__jail/usr/bin $__jail/bin"
eval "mv $__jail/usr/lib64 $__jail/lib64"

exit 0
