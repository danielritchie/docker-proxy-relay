#!/bin/bash

#Vars managed by start wrapper:
# proxy
# username
# domain

#config file path (default is set currently)
CNTML_CFG_FILE="/etc/cntml.conf"

#Substitue provided values in config file
sed -i "s/<username>/$username/g" $CNTML_CFG_FILE
sed -i "s/<proxy>/$proxy/g" $CNTML_CFG_FILE
sed -i "s/<domain>/$domain/g" $CNTML_CFG_FILE

#Update config file with hashed password value
echo "Auth         NTLM
" >> $CNTML_CFG_FILE
echo `cntlm -v -c /etc/cntlm.conf -M "http://www.google.com" <<<$password | grep PassNT` >> $CNTML_CFG_FILE
echo `cntlm -v -c /etc/cntlm.conf -M "http://www.google.com" <<<$password | grep PassLM` >> $CNTML_CFG_FILE

cntlm -c $CNTML_CFG_FILE
redsocks -c /etc/redsocks.conf