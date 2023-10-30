#!/bin/bash

pass=$(tail -c 1m /dev/urandom | md5sum | cut -d ' ' -f 1 | awk NF | cut -c 1-15)

echo "Place this script in the same directory with the certificate.zip file for your domain."$'\n'

read -p "What is the domain you are using?:  " domain

unzip cert*.zip

openssl pkcs12 -export -in fullchain*.pem -inkey privkey*.pem -out $domain.p12 -name $domain -passout pass:$pass

keytool -importkeystore -deststorepass $pass -destkeypass $pass -destkeystore $domain.store -srckeystore $domain.p12 -srcstoretype PKCS12 -srcstorepass $pass -alias $domain

keystore=$(ls *.store)
keystorepath=$(find / -name $keystore -print -quit 2>/dev/null)

echo $'\n'"The password generated is $pass"
echo "Insert the below text into your malleable profile of choice:"$'\n'

echo $'\n'"https-certificate {"$'\n'
echo "	set keystore \"$keystorepath\";"
echo "	set password \"$pass\";"
echo "}"
rm *.pem
