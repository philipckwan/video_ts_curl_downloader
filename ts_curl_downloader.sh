#!/bin/bash

# use this script to download multiple ts files then combine into one
#
# .ts file
# Example:
# $ ./ts_curl_downloader.sh 0 200 curl 0
# $ ./ts_curl_downloader.sh 201 500 curl 0
# $ ./ts_curl_downloader.sh 501 1100 curl 3
# $ ./ts_curl_downloader.sh 0 1100 cat 0
#
# .jpg file
# Example:
# $ ./ts_curl_downloader.sh 0 100 curl_jpg 0
# $ ./ts_curl_downloader.sh 0 100 curl_jpg 0 18
#
# this will be a master invocation of the program that will sprawn multiple (in this case 12) invocations of the same program in background
# only supports for the 'curl' mode
# Example:
# $ ./ts_curl_downloader.sh 0 1200 curl 0 12
#
# Decryption, after combine using 'cat', given a key (hex string) and an iv, use openssl to decrypt
#  the reference to the key file is in the .m3u8 file, the iv is directly displayed in the .m3u8 file
#  use "xxd" to read the hex string from the key file
#  i.e. $ xxd e052789f2f3c64bb.ts 
#  00000000: 9265 f8aa d463 07b3 672f 0a7d 891b 28d3  .e...c..g/.}..(.
# Then use openssl, e.g.:
# $ openssl enc -in out.ts -out out.d.ts -d -aes128 -K 9265f8aad46307b3672f0a7d891b28d3 -iv c3efcf45d895894a497a723243492fb6
# TODO: consider to make this part of this script
#

arg_start=$1
arg_end=$2
arg_mode=$3
arg_padding=$4
arg_split=$5

do_curl=0
do_curl_jpg=0
do_cat=0
do_clear=0
do_split=0
fmt="%00d"
split_num=1

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
  elif [ "curl_jpg" == "$arg_mode" ]
  then
    do_curl_jpg=1
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
		echo "arguments_check: ERROR - arg_mode is not specified correctly: arg_mode: [$arg_mode]"
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
    arg_padding=0
  fi
  echo "arguments_check: fmt: [$fmt]"

  if [ -z "$arg_split" ]
  then 
    do_split=0
  else
    do_split=1
    split_num=$arg_split
  fi
  echo "arguments_check: do_split: [$do_split]; split_num: [$split_num]"

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
    
function do_curl_split {
  let "total_files = $arg_end - $arg_start + 1"
  let "num_files_per_batch = $total_files / $split_num"

  for (( i=0; i<$split_num; i++ )); do \
    let "this_batch_start = $i * $num_files_per_batch + $arg_start"
    if ((i == split_num - 1)); then
      let "this_batch_end = $arg_end"
    else
      let "this_batch_end = ($i + 1) * $num_files_per_batch + $arg_start - 1"
    fi    
    bash ts_curl_downloader.sh $this_batch_start $this_batch_end curl $arg_padding &
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

function do_curl_jpg_split {
  let "total_files = $arg_end - $arg_start + 1"
  let "num_files_per_batch = $total_files / $split_num"

  for (( i=0; i<$split_num; i++ )); do \
    let "this_batch_start = $i * $num_files_per_batch + $arg_start"
    if ((i == split_num - 1)); then
      let "this_batch_end = $arg_end"
    else
      let "this_batch_end = ($i + 1) * $num_files_per_batch + $arg_start - 1"
    fi    
    bash ts_curl_downloader.sh $this_batch_start $this_batch_end curl_jpg $arg_padding &
  done
}

function do_curl_jpg {
  echo "do_curl_jpg: 1.0;"
  for (( i=$arg_start; i<=$arg_end; i++ )); do	\
    printf -v j "${fmt}" $i
    thisFile="$i.jpg"
    if [ -f $thisFile ]; then
      thisFileSize=`wc -c ${thisFile} | awk '{print $1}'`
      if [ $thisFileSize -gt $clear_threshold ]; then
        echo "do_curl: skipping file:${thisFile}; size:${thisFileSize};"
        continue
      fi
    fi  

curl 'https://abcde.com/image'$j'.jpg' \
  --compressed \
  -o $i.jpg
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
  if [ $do_split -eq 1 ]
  then
    do_curl_split
  else
    do_curl
  fi
fi

if [ $do_curl_jpg -eq 1 ]
then
  if [ $do_split -eq 1 ]
  then
    do_curl_jpg_split
  else
    do_curl_jpg
  fi
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