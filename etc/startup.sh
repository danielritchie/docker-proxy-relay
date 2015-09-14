#!/bin/bash

#Vars managed by startup wrapper:
# proxy
# username
# domain
# password

#config file path (default is set currently)
CNTML_CFG_FILE="/etc/cntlm.conf"

#Substitue provided values in config file
sed -i "s/<username>/$username/g" $CNTLM_CFG_FILE
sed -i "s/<proxy>/$proxy/g" $CNTLM_CFG_FILE
sed -i "s/<domain>/$domain/g" $CNTLM_CFG_FILE

#Update config file with hashed password value
echo "
Auth         NTLM
" >> $CNTLM_CFG_FILE
echo `cntlm -v -c $CNTLM_CFG_FILE -M "http://www.google.com" <<<$password | grep PassNT` >> $CNTLM_CFG_FILE
echo `cntlm -v -c $CNTLM_CFG_FILE -M "http://www.google.com" <<<$password | grep PassLM` >> $CNTLM_CFG_FILE
echo "
" >> $CNTLM_CFG_FILE

cntlm -c $CNTLM_CFG_FILE
redsocks -c /etc/redsocks.conf
