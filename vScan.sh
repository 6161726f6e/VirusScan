#!/bin/bash
# 
# Scan files using the VirusTotal API
#    -requires API key to be in .apikey file
# 
# TO DO: Process JSON return, instead of using simple grep
# 
# Author: Aaron Dhiman
# Date: 11/1/2021
# Ver: 0.11

export apikey=$(cat ./.apikey)

help(){
  echo "This script will scan individual files or full directories for viruses w/ VirusTotal"
  echo
  echo "Usage : ./${0##*/} [OPTION] {DATA}"
  echo "  Options:"
  echo "     -f [file]        Single file scan"
  echo "     -d [directory]   Full directory scan"
  echo "     -h               Help"
  echo
}

vScan(){ 
  #echo "apikey = $apikey"
  file="$1"
  echo "processing $file"
  sha="$(sha256sum "$file" | awk '{print $1}')"
  echo "SHA256 = $sha"
  url="https://www.virustotal.com/api/v3/files/${sha}"
  #echo "url = $url"
  #echo "sha = $sha"
  result="$(curl -s --connect-timeout 3 --retry 1 -H "X-Apikey: ${apikey}" $url | grep -i 'score\|harmless\|type-unsupported\|suspicious\|timeout\|failure\|malicious\|undetected')"
  #result="$(curl -s --connect-timeout 3 --retry 1 -H "X-Apikey: ${apikey}" $url)"
  echo -e "\n$result\n-------------------------"
  sleep 15
} 


case "$1" in

  -d)
    if [ ! -d "$2" ]; then
      echo "Error accessing $2: Does not exist."
      echo
      exit 1
    else
      export -f vScan
      find "$2" -type f -exec bash -c 'vScan "{}"' \;
    fi
  ;;


  -f)
    if [ ! -f "$2" ] ; then
      echo "Error accessing $2: Does not exist."
      echo
      exit 1
    else
      vScan "$2"
    fi
  ;;


  *)
    help
    exit 1
  ;;
esac
