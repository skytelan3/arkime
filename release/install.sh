#!/bin/bash
# PAPTH
ARKIME_INSTALL_DIR=`pwd`

# SETTING INFO
ARKIME_IP=192.168.143.46
KAFKA_IPPORT=192.168.143.46:9092
ELASTICSEARCH_IPPORT=192.168.143.46:9200
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

cd $ARKIME_INSTALL_DIR/bin
rm -rf arkime_add_user.sh
cp arkime_add_user.sh.bak arkime_add_user.sh 
chmod +x arkime_add_user.sh
sed -i "s@ARKIME_INSTALL_DIR@$ARKIME_INSTALL_DIR@g" $ARKIME_INSTALL_DIR/bin/arkime_add_user.sh

echo "################################"
echo "Elasticsearch INIT"
echo "################################"
cd $ARKIME_INSTALL_DIR
db/db.pl http://watchall:watchall@$ELASTICSEARCH_IPPORT init

echo "################################"
echo "Add Arkime User"
echo "################################"
bin/arkime_add_user.sh watchtek "Admin User" watchall --admin

echo "################################"
echo "Kafka Library install"
echo "################################"
rm -rf /usr/local/include/librdkafka
mkdir -p /usr/local/include/librdkafka
cp librdkafka/include/* /usr/local/include/librdkafka

mkdir -p /usr/local/lib/pkgconfig
rm -rf /usr/local/lib/pkgconfig/rdkafka*
rm -rf /usr/local/lib/librdkafka*
cp -r librdkafka/lib/* /usr/local/lib

systemctl daemon-reload
echo "Arkime Install End : `date`"
cd $ARKIME_INSTALL_DIR

