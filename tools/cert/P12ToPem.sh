#!/bin/bash
# --------------------------------------------
# P12 to PEM
# 
# zhangyanjin (zhangyanjin@bytedance.com)
# --------------------------------------------

echo "\n \$1为cert文件名，默认cert.p12； \$2为key文件名，默认key.p12; \$3为密码,默认bytedance\n"

certName="cert.p12"
if [[ $1 ]]; then
	certName=$1
fi

keyName="key.p12"
if [[ $2 ]]; then
	keyName=$2
fi

certPwd="bytedance"
if [[ $3 ]]; then
	certPwd=$3
fi

openssl pkcs12 -clcerts -nokeys -out cert.pem -in $certName -passin pass:$certPwd
openssl pkcs12 -nocerts -passout pass:$certPwd -out key.pem -in $keyName -passin pass:$certPwd
openssl rsa -in key.pem -passin pass:$certPwd -out key.unencrypted.pem
cat cert.pem key.unencrypted.pem > ck.pem

rm key.pem
rm cert.pem
rm key.unencrypted.pem

echo "finish!"
