#!/usr/bin/env bash
. ./spark_common.sh

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
  exit 1
fi

if [ -z "$SCALA_HOME" ]; then
  echo -e "ENV variable SCALA_HOME is not set. SCALA_HOME must be set"
  exit 1
fi

# install spark
eval 'spark-submit --version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  spark_version='spark-2.4.1'
  spark_home="/usr/spark/default"
  download_url="https://archive.apache.org/dist/spark/$spark_version/$spark_version-bin-hadoop2.7.tgz"

  if [ ! -d /usr/spark ]; then
    mkdir -pv /usr/spark
  fi

  echo "downloading $download_url..."
  cmd="curl -O $download_url \
    && tar -xvf  $spark_version-bin-hadoop2.7.tgz -C /usr/spark \
    && ln -s /usr/spark/$spark_version-bin-hadoop2.7 $spark_home \
    && rm -f $spark_version-bin-hadoop2.7.tgz"
  eval "$cmd"

  spark_checkpoint_dir="/tmp/spark/checkpoint"
  spark_logs_dir="$spark_home/logs"
  spark_work_dir="$spark_home/work"

  # spark nodes need a checkpoint directory to keep state should a node go down
  if [ ! -d "$spark_checkpoint_dir" ]; then
    mkdir -pv "$spark_checkpoint_dir" && chmod ugo+rw "$spark_checkpoint_dir/"
  fi

  # spark nodes need a logs directory
  if [ ! -d "$spark_logs_dir" ]; then
    mkdir -pv "$spark_logs_dir" && chmod ugo+rw "$spark_logs_dir"
  fi

  # spark workers need a work directory
  if [ ! -d "$spark_work_dir" ]; then
    mkdir -pv "$spark_work_dir" && chmod ugo+rw "$spark_work_dir"
  fi

  cat <<EOF >/etc/profile.d/spark.sh
export SPARK_HOME=$spark_home
export PATH=\$PATH:\$SPARK_HOME/bin
export \$SPARK_CHECKPOINT_DIR=$spark_checkpoint_dir
export \$SPARK_LOGS_DIR=$spark_logs_dir
export \$SPARK_WORK_DIR=$spark_work_dir
EOF

else
  echo -e "$SPARK_VERSION already appears to be installed. skipping."
fi
