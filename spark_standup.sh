#!/usr/bin/env bash
. ./spark_common.sh
cd $(dirname $0)

define_cluster_nodes

master=$(cat spark-cluster.info | grep MASTER_NODE |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')
echo "master: $master"
workers=$(cat spark-cluster.info | grep WORKER_NODE |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')
for worker in $workers; do
  echo "worker: $worker"
done
