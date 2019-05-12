#!/usr/bin/env bash
. ./spark_common.sh
cd $(dirname $0)

# if spark was installed by some other means than spark_install.sh, run define_cluster_nodes to create information about the cluster
define_cluster_nodes
