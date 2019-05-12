#!/usr/bin/env bash
. ./spark_common.sh

echo -e "About to cleanup runtime..."
sleep 1
spark_cleanup_runtime_local
