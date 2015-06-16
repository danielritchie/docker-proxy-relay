#!/bin/bash

sed -i "s/<username>/$username/g" /etc/cntlm.conf
sed -i "s/<proxy>/$proxy/g" /etc/cntlm.conf

cntlm -c /etc/cntlm.conf -P $password
redsocks -c /etc/redsocks.conf
