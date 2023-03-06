#!/bin/bash

# use this script to download multiple ts files then combine into one
# Example:
# >./ts_curl_downloader.sh 0 200 curl 0
# >./ts_curl_downloader.sh 201 500 curl 0
# >./ts_curl_downloader.sh 501 1100 curl 3
# >./ts_curl_downloader.sh 0 1100 cat 0
#

arg_start=$1
arg_end=$2
arg_mode=$3
arg_padding=$4

do_curl=0
do_cat=0
do_clear=0
fmt="%00d"

clear_threshold=3000

function arguments_check {
	if [ -z "$arg_start" ] || [ -z "$arg_end" ] || [ -z "$arg_mode" ]
	then
		echo "arguments_check: ERROR - start and/or end and/or mode are not specified"
		exit 1
	fi	

  if [ "both" == "$arg_mode" ]
	then
    do_curl=1
    do_cat=1
  elif [ "curl" == "$arg_mode" ]
  then
    do_curl=1
  elif [ "cat" == "$arg_mode" ]
  then 
    do_cat=1
  elif [ "clear" == "$arg_mode" ]
  then
    do_clear=1
  elif [ "none" == "$arg_mode" ]
  then 
    do_curl=0
    do_cat=0
  else
		echo "arguments_check: ERROR - arg_mode is not specified correctly"
		exit 1
	fi

  if [ -z "$arg_padding" ]
  then
    fmt="%00d"
  elif [ "1" == "$arg_padding" ]
  then
    fmt="%01d"
  elif [ "2" == "$arg_padding" ]
  then
    fmt="%02d"
  elif [ "3" == "$arg_padding" ]
  then
    fmt="%03d"
  elif [ "4" == "$arg_padding" ]
  then
    fmt="%04d"    
  else
    fmt="%00d"
  fi
  echo "arguments_check: fmt: [$fmt]"
}

function do_clear {
  echo "do_clear: 1.0;"
  for (( i=$arg_start; i<=$arg_end; i++ )); do	\
    printf -v thisFile "${fmt}.ts" $i
    if [ ! -f $thisFile ]; then
      continue
    fi
    thisFileSize=`wc -c ${thisFile} | awk '{print $1}'`
    if [ $thisFileSize -lt $clear_threshold ]; then
      echo "will rm this file:${thisFile}; size:${thisFileSize};"
      rm -rf $thisFile
    fi
  done
}
    
function do_curl_mod {
  echo "do_curl: 1.1; fmt:[$fmt];"
  for (( i=$arg_start; i<=$arg_end; i++ )); do	\
    printf -v j "${fmt}" $i
    echo "j: [$j]"
  done
}

function do_curl {
  echo "do_curl: 1.0;"
  for (( i=$arg_start; i<=$arg_end; i++ )); do	\
    printf -v j "${fmt}" $i
    thisFile="$i.ts"
    if [ -f $thisFile ]; then
      thisFileSize=`wc -c ${thisFile} | awk '{print $1}'`
      if [ $thisFileSize -gt $clear_threshold ]; then
        echo "do_curl: skipping file:${thisFile}; size:${thisFileSize};"
        continue
      fi
    fi
curl 'https://abcde.com/video'$j'.ts' \
  --compressed \
  -o $i.ts
    echo "${i}/${arg_end} done"
  done
}

function do_cat {
  echo "do_cat: 1.0;"
  for (( i=$arg_start; i<=$arg_end; i++ )); do	\
    cat $i.ts >> out.ts
  done
}

arguments_check

if [ $do_curl -eq 1 ]
then
  do_curl
fi

if [ $do_cat -eq 1 ]
then
  do_cat
fi

if [ $do_clear -eq 1 ]
then
  do_clear
fi

exit 0