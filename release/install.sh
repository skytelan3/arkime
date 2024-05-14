#!/bin/bash
# PAPTH
ARKIME_INSTALL_DIR=`pwd`

# SETTING INFO
ARKIME_IP=192.168.143.46
KAFKA_IPPORT=localhost:9092
ELASTICSEARCH_IPPORT=localhost:9200
INTERFACE_LIST=enp0s3
PCAP_DIR_LIST=$ARKIME_INSTALL_DIR/raw

echo "################################"
echo "Arkime Install Start : `date`"
echo "################################"

cd $ARKIME_INSTALL_DIR/etc
rm -rf config.ini
cp config.watchtek config.ini
sed -i "s@ARKIME_INSTALL_DIR@$ARKIME_INSTALL_DIR@g" config.ini
sed -i "s/ARKIME_IP/$ARKIME_IP/g" config.ini
sed -i "s/KAFKA_IPPORT/$KAFKA_IPPORT/g" config.ini
sed -i "s/ELASTICSEARCH_IPPORT/$ELASTICSEARCH_IPPORT/g" config.ini
sed -i "s/INTERFACE_LIST/$INTERFACE_LIST/g" config.ini
sed -i "s@PCAP_DIR_LIST@$PCAP_DIR_LIST@g" config.ini

mv ipv4-address-space.csv.sample ipv4-address-space.csv

echo "################################"
echo "Elasticsearch INIT"
echo "################################"
cd $ARKIME_INSTALL_DIR
db/db.pl http://watchall:watchall@$ELASTICSEARCH_IPPORT init

echo "################################"
echo "Add Arkime User"
echo "################################"
bin/arkime_add_user.sh watchtek "Admin User" watchall --admin

echo "Arkime Install End : `date`"
cd $ARKIME_INSTALL_DIR

