#!/bin/bash
# mwlove.sh - a script to test htaccess rules using MadeWithLove's online tool, https://htaccess.madewithlove.be/

filename=./.htaccess
url='';
usage(){
    echo "usage: mwlove [[[-f|--file] htaccess-file ] url | [-h|--help]]"
    echo "-h|--help   print this help information."
    echo "-f|--file   provide an optional file of htaccess rules. If no files are provided, the script will try to load '.htaccess' file found in the current folder."
    echo "url         a URL path to test against the redirect rules."
    echo
    echo "OUTPUT: <htaccess line matched>,<rule matched>,<redirect url."
    echo "The output is a CSV formated line with the line number in the htaccess file which matched the url, the actuall line of the htaccess rule matched and the redirect url."
    echo "NOTE: you can also pipe a list of urls to validate into the command."
    echo "Examples:"
    echo "validate a simple url against a htacccess file rules"
    echo "    ./mwlove.sh -f /var/www/.htaccess http://mydomain.com/old-page/"
    echo
    echo "validate a list of urls,"
    echo "    cat list-of-urls.txt | ./mwlove.sh -f /var/www/.htaccess"
}
madewithlove(){
  rsp=$(curl --silent --data-urlencode "htaccess@${filename}" --data "url=${url}" https://htaccess.madewithlove.be/api)
  #echo $rsp
  red=$(jq -r '.output_url' <<< "${rsp}")
  ht=""
  # echo $lines
  idx=0
  found=false
  ht='-1,no match found,'$url
  while IFS= read -r ismet && IFS= read -r value; do
    ((idx++))
    if [ "$ismet" = "true" ] && [[ $value == RewriteRule* ]];then
      ht=$(echo ${map_lines[$idx]},${value},$red)
      found=true
    elif $found ; then
      break
    fi
  done < <(jq -r '.lines[] | (.isMet,.value)' <<< "${rsp}")
  #echo results
  echo $ht
}
trim () {
  read -rd '' $1 <<<"${!1}"
}
##### Main
command -v jq >/dev/null 2>&1 || { echo >&2 "Command jq not found, please install jq."; exit 1; }

if [ "$1" = "" ]; then
  usage
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    -f | --file ) shift
                  filename=$1
                  shift
                  url=$1
                  ;;
    -h | --help ) usage
                  exit
                  ;;
    * )           usage
                  exit 1
  esac
  shift
done
#does the supplied file exists.
if [ ! -f $filename ]; then
  echo "file "$filename" not found, use a valid htaccess file."
  exit 1
fi
#is it readable
if [ ! -r $filename ]; then
  echo "file "$filename" not readable, make you have read access to the file."
  exit 1
fi
#does the file contain something.
if [ ! -s $filename ]; then
  echo "file "$filename" is empty, use a valid htaccess file."
  exit 1
fi
#scan htaccess file.
declare -A map_lines
il=0
ml=0
while read line; do
  ((il++))
  trim line
  if [ "$line" != "" ] && [ "${line:0:1}" != "#" ]; then
    ((ml++))
    map_lines[$ml]=$il
  fi
done < $filename
# for K in "${!map_lines[@]}"; do echo $K:${map_lines[$K]}; done
#simple url validation.
if [ -p /dev/stdin ]; then
  while IFS= read url; do
    check="$(echo ${url} | grep -e '^http[s]\{0,1\}://.*$')"
    if [ "$check" = "" ]; then
      echo "invalid url"
    else
      madewithlove
    fi
  done
else
  check="$(echo ${url} | grep -e '^http[s]\{0,1\}://.*$')"
  if [ "$check" = "" ]; then
    echo "The url provided: "${url}" is not valid"
    exit 1
  fi
  madewithlove
fi
