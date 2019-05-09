#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  echo -e "Jdk8 is not installed. Install Jdk8"
  exit 1
fi

if [ -z "$JAVA_HOME" ]; then
  echo -e "ENV variable JAVA_HOME is not set. JAVA_HOME must be set"
  exit 1
fi

if [ -z "$SPARK_HOME" ]; then
  echo "ENV variable SPARK_HOME is not set. SPARK_HOME must be set"
  return 1
fi

SPARK_MASTER_IP=192.168.1.81
SPARK_SLAVE01_IP=192.168.1.81
SPARK_SLAVE02_IP=192.168.1.82
SPARK_SLAVES="$SPARK_SLAVE01_IP
$SPARK_SLAVE02_IP"
local_ip_address=$(ifconfig |egrep 'inet\W' |grep -v '127.0.0.1' | awk '{print $2}')

# all nodes
if [ ! -d /tmp/spark/data ]; then
  mkdir -pv /tmp/spark/data
  chmod ugo+w /tmp/spark/data/
fi

# all nodes
if [ ! -d /tmp/spark/worker ]; then
  mkdir -pv /tmp/sp/work
  chmod ugo+w /tmp/spark/work/
fi

# all nodes
if [ ! -d /tmp/spark/checkpoint ]; then
  mkdir -pv /tmp/sp/checkpoint
  chmod ugo+w /tmp/spark/checkpoint/
fi

# all nodes
cp -fv $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
cat <<EOF >$SPARK_HOME/conf/spark-env.sh
SPARK_DAEMON_MEMORY=1g
SPARK_WORKER_INSTANCES=2
SPARK_HOME=/usr/spark/default
SPARK_LOCAL_DIRS=/tmp/spark/data
SPARK_WORKER_MEMORY=2g
SPARK_WORKER_WEBUI_PORT=9082
SPARK_WORKER_DIR=/tmp/spark/work
SPARK_MASTER_HOST=engine1
SPARK_MASTER_PORT=7077
SPARK_MASTER_WEBUI_PORT=9081
EOF
chmod +x $SPARK_HOME/conf/spark-env.sh

# master node
cp -fv $SPARK_HOME/conf/slaves.template $SPARK_HOME/conf/slaves
cat <<EOF >$SPARK_HOME/conf/slaves
$SPARK_SLAVE01_IP
$SPARK_SLAVE02_IP
EOF

cp -fv $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
cat <<EOF >$SPARK_HOME/conf/spark-defaults.conf
spark.master spark://$SPARK_MASTER_IP:7077
EOF
