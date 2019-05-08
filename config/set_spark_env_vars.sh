#!/usr/bin/env bash


export SCALA_HOME=/usr/scala/default
export SPARK_WORKER_INSTANCES=2

# Environment Variable	Meaning
# SPARK_MASTER_HOST	Bind the master to a specific hostname or IP address, for example a public one.
export SPARK_MASTER_HOST=engine1
# SPARK_MASTER_PORT	Start the master on a different port (default: 7077).
export SPARK_MASTER_PORT=7077
# SPARK_MASTER_WEBUI_PORT	Port for the master web UI (default: 8080).
export SPARK_MASTER_PORT=9080
# SPARK_MASTER_OPTS	Configuration properties that apply only to the master in the form "-Dx=y" (default: none). See below for a list of possible options.
# SPARK_LOCAL_DIRS	Directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk. This should be on a fast, local disk in your system. It can also be a comma-separated list of multiple directories on different disks.
export SPARK_LOCAL_DIRS=/spark/data
# SPARK_WORKER_CORES	Total number of cores to allow Spark applications to use on the machine (default: all available cores).
# SPARK_WORKER_MEMORY	Total amount of memory to allow Spark applications to use on the machine, e.g. 1000m, 2g (default: total memory minus 1 GB); note that each application's individual memory is configured using its spark.executor.memory property.
export SPARK_WORKER_MEMORY=2g
# SPARK_WORKER_PORT	Start the Spark worker on a specific port (default: random).
# SPARK_WORKER_WEBUI_PORT	Port for the worker web UI (default: 8081).
export SPARK_WORKER_WEBUI_PORT=9081
# SPARK_WORKER_DIR	Directory to run applications in, which will include both logs and scratch space (default: SPARK_HOME/work).
export SPARK_WORKER_DIR=/spark/worker
# SPARK_WORKER_OPTS	Configuration properties that apply only to the worker in the form "-Dx=y" (default: none). See below for a list of possible options.
# SPARK_DAEMON_MEMORY	Memory to allocate to the Spark master and worker daemons themselves (default: 1g).
export SPARK_DAEMON_MEMORY=1g
# SPARK_DAEMON_JAVA_OPTS	JVM options for the Spark master and worker daemons themselves in the form "-Dx=y" (default: none).
# SPARK_DAEMON_CLASSPATH	Classpath for the Spark master and worker daemons themselves (default: none).
# SPARK_PUBLIC_DNS	The public DNS name of the Spark master and workers (default: none).
