#!/usr/bin/env bash
. ./spark_common.sh
cd $(dirname $0)

echo -e "About to stop slave nodes..."
sleep 1
spark_stop_slaves

echo -e "About to stop master node..."
sleep 1
spark_stop_master

echo -e "About to cleanup runtime..."
spark_cleanup_runtime_local
