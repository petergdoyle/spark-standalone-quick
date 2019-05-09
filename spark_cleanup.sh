#!/usr/bin/env bash

cmd="rm -frv $SPARK_HOME/logs/*"
read -n 1 -s -r -p "About to delete contents under $SPARK_HOME/logs/. Press any key to continue"
eval "$cmd"

cmd="rrm -fvr /tmp/spark/*/*"
read -n 1 -s -r -p "About to delete contents under $SPARK_HOME/logs/. Press any key to continue"
eval "$cmd"
