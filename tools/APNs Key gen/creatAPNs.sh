#使用方法 bash creatAPNs.sh cert_name key_name
certName=$1
keyName=$2
openssl pkcs12 -clcerts -nokeys -out cert.pem -in "$certName"
openssl pkcs12 -nocerts -out key.pem -in "$keyName"
openssl rsa -in key.pem -out key.unencrypted.pem
cat cert.pem key.unencrypted.pem > ck.pem