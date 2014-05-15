#!/bin/bash
#
#Very Simpleminded directory "list like tree" script 
#Usage: ./filetree.sh directory

#The package " tree - displays directory tree, in color " does much better 
 
#color
NORMAL="\033[00m" # global default, although everything should be something.
FILE="\033[00m" # normal file
DIR="\033[01;34m" # directory
LINK="\033[01;36m" # symbolic link
FIFO="\033[40;33m" # pipe
SOCK="\033[01;35m" # socket
EXEC="\033[01;32m"  #execute
BLK="\033[40;33;01m" # block device driver
CHR="\033[40;33;01m" # character device driver
ORPHAN="\033[01;05;37;41m" # orphaned syminks
MISSING="\033[01;05;37;41m" # ... and the files they point to 
 
  search () {
  for i in  *
  do
    zz=0                    # ==> Temp variable, keeping track of directory level.
 
    while [ $zz != $1 ]     # Keep track of inner nested loop.
      do
        echo -n "| "        # ==> Display vertical connector symbol,
                            # ==> with 2 spaces & no line feed in order to indent.
        zz=`expr $zz + 1`   # ==> Increment zz.
      done
    if [ -d "$i" ] ; then # ==> If it is a directory (-d)...
      if [ -L "$i" ] ; then # ==> If directory is a symbolic link...
        echo  -e "+--${LINK}$i${NORMAL}" `ls -l $i | sed 's/^.*'$i' //'`
        # ==> Display horiz. connector and list directory name, but...
        # ==> delete date/time part of long listing.
      else

        echo  -e "+--${DIR}$i${NORMAL}"       # ==> Display horizontal connector symbol...
        # ==> and print directory name.
        numdirs=`expr $numdirs + 1` # ==> Increment directory count.
        if cd "$i" ; then         # ==> If can move to subdirectory...
          search `expr $1 + 1`      # with recursion ;-)
          # ==> Function calls itself.
          cd ..
        fi
      fi
   else
      if [ -L "$i" ] ; then #If file is a symbolic link
        echo -e "---${LINK}$i${NORMAL}" `ls -l $i | sed 's/^.*'$i' //'`
      elif [ -p "$i" ] ; then #If file  is a named pipe
   echo -e "---${FIFO}$i${NORMAL}"
      elif [ -S "$i" ] ; then #If file is a socket
   echo -e "---${SOCK}$i${NORMAL}"
      elif [ -x "$i" ] ; then #If file's execute (or search) permission is granted
   echo -e "---${EXEC}$i${NORMAL}"
      elif [ -b "$i" ] ; then #If file is block special
   echo -e  "---${BLK}$i${NORMAL}"
      elif [ -c "$i" ] ; then #If file is character special
   echo -e  "---${CHR}$i${NORMAL}"
      else
   echo -e "---${FILE}$i${NORMAL}"
      fi
      ((numfiles+=1))    #Increment file count
    fi
  done
  }
 
  if [ $# != 0 ] ; then
    cd $1 # move to indicated directory.
    #else # stay in current directory
  fi
 
  echo "Initial directory = `pwd`"
  numdirs=0
  numfiles=0
 
  search 0
  echo "Total directories = $numdirs ,total files = $numfiles"
  exit 0
