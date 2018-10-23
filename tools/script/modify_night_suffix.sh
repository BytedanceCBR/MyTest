#!/bin/bash


destdir="/Users/huaqingluo/svn_image/5.0_night"
srcdir="/Users/huaqingluo/svn_image/5.0/night/ios/"
copy_ui()
{
  local srcdir="$1"
  night_dir=`echo -n "$item" | sed -e '#/daymode/#/nightmode/#'`
  is_night=0
  if [ "$srcdir" != "$night_dir" ]; then
  is_night=1
  fi
  for item  in `find "$srcdir" -name '*.png' -o -name '*.jpg' | grep -v '.9.png' | grep -v '@480x800.png' | grep -v 'android'`
  do
   dname=`basename "$item"`
   if [ $is_night = 1 ]; then
    dname=`echo "$dname" | sed -E -e 's/^([^@]+)(@2x|~ipad|@2x~ipad|@3x)?\.(png|jpg)$/\1_night\2.\3/'`
   fi
    cp "$item" "$destdir/${dname}"
  done
}

copy_ui "$srcdir"
