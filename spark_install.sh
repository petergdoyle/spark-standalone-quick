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

# install spark 2.11
eval 'spark-submit --version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  spark_home="/usr/spark/default"
  download_url="http://apache.mirrors.hoobly.com/spark/spark-2.4.2/spark-2.4.2-bin-hadoop2.7.tgz"

  if [ ! -d /usr/spark ]; then
    mkdir -pv /usr/spark
  fi

  echo "downloading $download_url..."
  cmd="curl -O $download_url \
    && tar -xvf  spark-2.4.2-bin-hadoop2.7.tgz -C /usr/spark \
    && ln -s /usr/spark/spark-2.4.2-bin-hadoop2.7 $spark_home \
    && rm -f spark-2.4.2-bin-hadoop2.7.tgz"
  eval "$cmd"

  export SPARK_HOME=$spark_home
  cat <<EOF >/etc/profile.d/spark.sh
export SPARK_HOME=$SPARK_HOME
export PATH=\$PATH:\$SPARK_HOME/bin
export PATH=\$PATH:\$SPARK_HOME/sbin
EOF
  # spark nodes need a checkpoint directory to keep state should a node go down
  if [ ! -d "/spark/checkpoint" ]; then
    mkdir -pv "/spark/checkpoint"
    chmod ugo+rw "/spark/checkpoint/"
  fi

  # spark nodes need a logs directory
  if [ ! -d "/usr/spark/default/logs" ]; then
    mkdir -pv "/usr/spark/default/logs"
    chmod ugo+rw "/usr/spark/default/logs"
  fi

  # spark workers need a work directory
  if [ ! -d "/usr/spark/default/work" ]; then
    mkdir -pv "/usr/spark/default/work"
    chmod ugo+rw "/usr/spark/default/work"
  fi



else
  echo -e "spark-2.11 already appears to be installed. skipping."
fi
