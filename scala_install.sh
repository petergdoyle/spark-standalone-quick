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

# install scala 2.11
eval 'scala -version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  scala_version="2.11.12"
  scala_home="/usr/scala/default"
  download_url="https://downloads.lightbend.com/scala/$scala_version/scala-$scala_version.tgz"

  if [ ! -d /usr/scala ]; then
    mkdir -pv /usr/scala
  fi

  echo "downloading $download_url..."
  cmd="curl -O $download_url \
    && tar -xvf  scala-$scala_version.tgz -C /usr/scala \
    && ln -s /usr/scala/scala-$scala_version $scala_home \
    && rm -f scala-$scala_version.tgz"
  eval "$cmd"

  if [ ! -f /etc/profile.d/scala.sh ]; then
    cat <<EOF >/etc/profile.d/scala.sh
export SCALA_HOME=$scala_home
export PATH=\$PATH:\$SCALA_HOME/bin
export \$SCALA_VERSION=$scala_version
EOF
  fi

else
  echo -e "scala-2.11 already appears to be installed. skipping."
fi
