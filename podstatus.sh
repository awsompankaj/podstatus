#/bin/bash

# ======================================================================
# SCRIPT NAME: podstatus.sh
# PURPOSE:  list pods which are not running or not in ready state and
#           their age is less than 5 Minutes
# REVISION HISTORY:
# AUTHOR                 DATE                   DETAILS
# --------------------- --------------- --------------------------------
# Pankaj Sharma          6-June-2020           Initial version
# ======================================================================

####### PURGING RESULT FILES ##########

>/tmp/podnotrunning
>/tmp/podnotready
>/tmp/podage

####### GET NOT READY PODS ###########

oc get pods  -o json  | jq -r '.items[] | select(.status.phase != "Running" or ([ .status.conditions[] | select(.type == "Ready" and .status == "False") ] | length ) == 1 ) |  .metadata.name' > /tmp/podnotready

###### GET LIST OF PODS WHICH ARE NOT IN RUNNING STATE ############
oc get pods --field-selector=status.phase!=Running | awk 'NR>1{print $1}'  | grep -v resource > /tmp/podnotrunning

##### GET LIST OF PODS WHOSE AGE IS LESS THAN 5 MINS############
oc get pods -o go-template --template '{{range .items}}{{.metadata.name}} {{.metadata.creationTimestamp}}{{"\n"}}{{end}}' | awk '$2 >= "'$(date -d'now-5 minutes' -Ins --utc | sed 's/+0000/Z/')'" { print $1 }' > /tmp/podage

########### PUTTING RESULT IN FILES  ##########

f1="/tmp/podnotrunning"
f2="/tmp/podnotready"
f3="/tmp/podage"
podstatus=$(cat "/tmp/podnotrunning")
podready=$(cat "/tmp/podnotready")
podage=$(cat "/tmp/podage")

if [ -s $f1 ]
then
  for a in `cat /tmp/podnotrunning`
  do
  echo "$a are not running";
  done
fi
if [ -s $f2 ]
then
  for b in `cat /tmp/podnotready`
  do
  echo "$b are not ready";
  done
fi
if [ -s $f3 ]
then
  for c in `cat /tmp/podage`
  do
  echo "pod $c age is less than 5 mins";
  done
fi
