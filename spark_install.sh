#!/usr/bin/env bash

java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  echo -e "Jdk8 is not installed. Install Jdk8"
  exit 1
fi

if [ -z "$JAVA_HOME" ]; then
  echo -e "ENV variable JAVA_HOME is not set. JAVA_HOME must be set"
  exit 1
fi

eval 'scala -version' > /dev/null 2>&1
if [ $? -eq 127 ]; then
  echo -e "Scala is not installed. Install Scala"
fi

if [ -z "$SCALA_HOME" ]; then
  echo -e "ENV variable SCALA_HOME is not set. SCALA_HOME must be set"
  exit 1
fi

SPARK_VERSION='2.4.1'

# install spark
eval 'spark-submit --version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  spark_home="/usr/spark/default"
  download_url="https://archive.apache.org/dist/tmp/spark/$SPARK_VERSION/$SPARK_VERSION-bin-hadoop2.7.tgz"

  if [ ! -d /usr/spark ]; then
    mkdir -pv /usr/spark
  fi

  echo "downloading $download_url..."
  cmd="curl -O $download_url \
    && tar -xvf  $SPARK_VERSION-bin-hadoop2.7.tgz -C /usr/spark \
    && ln -s /usr/spark/$SPARK_VERSION-bin-hadoop2.7 $spark_home \
    && rm -f $SPARK_VERSION-bin-hadoop2.7.tgz"
  eval "$cmd"

  export SPARK_HOME=$spark_home
  cat <<EOF >/etc/profile.d/spark.sh
export SPARK_HOME=$SPARK_HOME
export PATH=\$PATH:\$SPARK_HOME/bin
export PATH=\$PATH:\$SPARK_HOME/sbin
EOF

else
  echo -e "$SPARK_VERSION already appears to be installed. skipping."
fi
