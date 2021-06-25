#!/bin/bash
: ${REGION:=$(aws configure get region)}
: ${ACCOUNT_ID:=$(aws sts get-caller-identity|jq -r ".Account")}
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
  logger "red" "******************install live stream server*****************"
  logger "green" "These are the environment settings that are going to be used:"
  logger "yellow" "AWS Region   : $REGION"
  logger "yellow" "Account ID   : $ACCOUNT_ID"
}

vpc(){
logger "red" "create vpc"
./stack-up.sh vpc
}

assets()
{
logger "red" "create s3"
./stack-up.sh assets
}

dynamodb()
{
logger "red" "create dynamodb"
./stack-up.sh dynamodb
}

security()
{
logger "red" "create security group"
./stack-up.sh security
}

redis()
{
logger "red" "create redis "
./stack-up.sh redis
}

ecs()
{
logger "red" "create ecs "
./stack-up.sh ecs-ec2
}

proxy(){
proxy/stacks/install.sh
}

server(){
server/stacks/install.sh
}

processor(){
processor/stacks/install.sh
}

origin(){
origin/stacks/install.sh
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