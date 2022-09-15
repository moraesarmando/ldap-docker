#!/bin/bash

# setar env HOSTNAME e RAIZ_BASE_LDAP para iniciar o container

export RAIZ_BASE_LDAP="dc="`echo $DOMINIO_INST | sed -e 's/\./,dc=/g'`


# popula LDAP caso seja um container novo
if [ ! -f /var/lib/ldap/.populado ]; then
  
#  # certificado SSL
#  if [ ! -f "/etc/ldap/$HOSTNAME.key" ];then
#    sed -i "s/\$HOSTNAME/$HOSTNAME/g" /scripts/openssl.cnf
#    openssl genrsa -out /etc/ldap/$HOSTNAME.key 2048 -config /scripts/openssl.cnf
#    openssl req -new -key /etc/ldap/$HOSTNAME.key -out /etc/ldap/$HOSTNAME.csr -batch -config /scripts/openssl.cnf
#    openssl x509 -req -days 730 -in /etc/ldap/$HOSTNAME.csr -signkey /etc/ldap/$HOSTNAME.key -out /etc/ldap/$HOSTNAME.crt
#  fi;

 
  sed -i "s/\$[{]RAIZ_BASE_LDAP[}]/$RAIZ_BASE_LDAP/g" /etc/ldap/slapd.conf
 
  sed -i "s/TLSCACertificateFile/#TLSCACertificateFile/g" /etc/ldap/slapd.conf
  sed -i "s/TLSCertificateFile/#TLSCertificateFile/g" /etc/ldap/slapd.conf
  sed -i "s/TLSCertificateKeyFile/#TLSCertificateKeyFile/g" /etc/ldap/slapd.conf

  sed -i "s/\$[{]RAIZ_BASE_LDAP[}]/$RAIZ_BASE_LDAP/g" /etc/ldap/ldap.conf
  sed -i "s/\$[{]NOME_ARQUIVO[}]/$HOSTNAME/g" /etc/ldap/ldap.conf
  sed -i "s/\$[{]HOSTNAME[}]/$HOSTNAME/g" /etc/ldap/slapd.conf
  
  rm -rf /etc/ldap/slapd.d/*
  slaptest -f /etc/ldap/slapd.conf -F /etc/ldap/slapd.d
  chown openldap:openldap -R /etc/ldap/
  
  sed -i "s/DOMINIO_INST=.*//" /scripts/popula.sh
  sed -i "s/^SENHA_ADMIN=.*/SENHA_ADMIN=${SENHA_ADMIN:=1234}/" /scripts/popula.sh
  sed -i "s/^SENHA_LEITOR_SHIB=.*/SENHA_LEITOR_SHIB=${SENHA_LEITOR_SHIB:=00123456}/" /scripts/popula.sh
  
  echo "Populando base $RAIZ_BASE_LDAP"
  /scripts/popula.sh && touch /var/lib/ldap/.populado
  
fi


# inicia servico
exec slapd -h "ldap:/// ldaps:///" -f /etc/ldap/slapd.conf -d stats