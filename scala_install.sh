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

# install scala 2.11
eval 'scala -version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  scala_home="/usr/scala/default"
  download_url="https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.tgz"

  if [ ! -d /usr/scala ]; then
    mkdir -pv /usr/scala
  fi

  echo "downloading $download_url..."
  cmd="curl -O $download_url \
    && tar -xvf  scala-2.11.12.tgz -C /usr/scala \
    && ln -s /usr/scala/scala-2.11.12 $scala_home \
    && rm -f scala-2.11.12.tgz"
  eval "$cmd"

  if [ ! -f /etc/profile.d/scala.sh ]; then
    export SCALA_HOME=$scala_home
    cat <<EOF >/etc/profile.d/scala.sh
export SCALA_HOME=$SCALA_HOME
export PATH=\$PATH:\$SCALA_HOME/bin
EOF
  fi

else
  echo -e "scala-2.11 already appears to be installed. skipping."
fi
