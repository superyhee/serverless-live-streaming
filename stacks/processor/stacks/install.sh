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
  logger "red" "***********************************"
  logger "red" "***  install processor service  ***"
  logger "red" "***********************************"
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

build()
{
  docker build -t video-streaming-processor ../  
}

tag()
{

  if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]];
      then
 docker tag video-streaming-processor $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com.cn/video-streaming-processor:latest   

      else
 docker tag video-streaming-processor $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/video-streaming-processor:latest   
fi
}

push()
{
    if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]];
      then
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com.cn/video-streaming-processor:latest  

      else
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/video-streaming-processor:latest  
fi
}

ecr()
{
        aws cloudformation deploy \
        --template-file processor/stacks/ecr.stack.yml \
        --stack-name video-streaming-processor-ecr \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
        RepositoryName=video-streaming-processor \
        ${PROFILE}
}

service()
{
if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]];
      then
        aws cloudformation deploy \
        --template-file processor/stacks/service.stack-cn.yml \
        --stack-name video-streaming-processor \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
        Version=1.0.15 \
        DesiredCount=1 \
        RedisStack=video-streaming-redis \
        ${PROFILE}me=video-streaming-processor \
        ${PROFILE}
      else
        aws cloudformation deploy \
        --template-file processor/stacks/service.stack.yml \
        --stack-name video-streaming-processor \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
        Version=1.0.15 \
        DesiredCount=1 \
        RedisStack=video-streaming-redis \
        ${PROFILE}
fi
}

main() {
welcome
# ecr
# tag
# push
service
}

main