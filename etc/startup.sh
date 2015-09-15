#!/bin/bash

#Set the config file - /etc/cntlm.conf is the default
CNTLM_CONFIG_FILE="/etc/cntlm.conf"

#Replace passed values in template
sed -i "s/<username>/$username/g" $CNTLM_CONFIG_FILE
sed -i "s/<proxy>/$proxy/g" $CNTLM_CONFIG_FILE
sed -i "s/<domain>/$domain/g" $CNTLM_CONFIG_FILE

#Encrypt password and update config file
echo "
Auth            NTLM
" >> $CNTLM_CONFIG_FILE
echo `cntlm -v -c $CNTLM_CONFIG_FILE -M "http://www.google.com" <<<$password | grep PassNT` >> $CNTLM_CONFIG_FILE
echo `cntlm -v -c $CNTLM_CONFIG_FILE -M "http://www.google.com" <<<$password | grep PassLM` >> $CNTLM_CONFIG_FILE
echo "
" >> $CNTLM_CONFIG_FILE

cntlm -c $CNTLM_CONFIG_FILE
redsocks -c /etc/redsocks.conf
