#!/bin/bash
source /root/envs.sh

# Generate the NGINX config
node index.js ./nginx.conf.template ./nginx.conf.bak 

