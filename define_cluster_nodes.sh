#!/usr/bin/env bash
. ./spark_common.sh

# if spark was installed by some other means than spark_install.sh, run define_cluster_nodes to create information about the cluster 
define_cluster_nodes
