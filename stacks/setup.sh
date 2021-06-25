#!/bin/bash
: ${REGION:=$(aws configure get region)}
: ${ACCOUNT_ID:=$(aws sts get-caller-identity|jq -r ".Account")}

export LOG_OUTPUT="media_processor.log"
###########################################################
###########                                     ###########
###########################################################

logger() {
  LOG_TYPE=$1
  MSG=$2

  COLOR_OFF="\x1b[39;49;00m"
  case "${LOG_TYPE}" in
      green)
          # Green
          COLOR_ON="\x1b[32;01m";;
      blue)
          # Blue
          COLOR_ON="\x1b[36;01m";;
      yellow)
          # Yellow
          COLOR_ON="\x1b[33;01m";;
      red)
          # Red
          COLOR_ON="\x1b[31;01m";;
      default)
          # Default
          COLOR_ON="${COLOR_OFF}";;
      *)
          # Default
          COLOR_ON="${COLOR_OFF}";;
  esac

  TIME=$(date +%F" "%H:%M:%S)
  echo -e "${COLOR_ON} ${TIME} -- ${MSG} ${COLOR_OFF}"
#  echo -e "${TIME} -- ${MSG}" >> "${LOG_OUTPUT}"
}

errorcheck() {
   if [ $? != 0 ]; then
          logger "red" "Unrecoverable generic error found in function: [$1]. Check the log. Exiting."
      exit 1
   fi
}

welcome() {
  logger "red" "*** install live stream server ***"
#   logger "green" "These are the environment settings that are going to be used:"
  logger "yellow" "AWS Region   : $REGION"
  logger "yellow" "Account ID   : $ACCOUNT_ID"
}

vpc(){
logger "red" "*** create vpc ***"
./stack-up.sh vpc 
logger "red" "*** create vpc succeed ***"
}

assets()
{
logger "red" "*** create assets ***"
./stack-up.sh assets 
logger "red" "*** create assets succeed ***"
}

efs()
{
logger "red" "*** create efs ***"
./stack-up.sh efs 
logger "red" "*** create efs succeed ***"
}

dynamodb()
{
logger "red" "*** create dynamodb ***"
./stack-up.sh dynamodb 
logger "red" "*** create dynamodb succeed ***"
}

security()
{
logger "red" "*** create security ***"
./stack-up.sh security
logger "red" "*** create security succeed ***"
}

redis()
{
logger "red" "*** create redis ***"
./stack-up.sh redis
logger "red" "*** create redis succeed ***"
}

ecs()
{
logger "red" "*** create ecs ***"
./stack-up.sh ecs
logger "red" "*** create ecs succeed ***"
}

proxy(){
proxy/stacks/install.sh
logger "red" "*** create proxy service succeed ***"
}

server(){
server/stacks/install.sh
logger "red" "*** create server service succeed ***"
}

processor(){
processor/stacks/install.sh
logger "red" "*** create processor service succeed ***"
}

origin(){
origin/stacks/install.sh
logger "red" "*** create origin service succeed ***"
}

web(){
web/stacks/install.sh
logger "red" "*** create origin service succeed ***"
}

get-login()
{

if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]]; 
      then 
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com.cn  

      else
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
fi
}

main() {
welcome
vpc
assets
dynamodb
security
efs
redis
ecs
get-login
proxy
processor
server
origin
web
}

main