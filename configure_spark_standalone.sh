#!/usr/bin/env bash
. ./spark_common.sh

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

if [ -z "$SPARK_HOME" ]; then
  echo "ENV variable SPARK_HOME is not set. SPARK_HOME must be set"
  exit 1
fi

if [ ! -d $SPARK_HOME/ ] || [ find $SPARK_HOME/ -type f > /dev/null 2>&1 ]; then
  echo "$SPARK_HOME doesn't exist or is empty. Run spark_install.sh and make sure you log out and back in to set all ENV variables"
  exit 1
fi

define_cluster_nodes

master_node_ip=$(cat conf/spark-cluster.info | grep MASTER_NODE |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')
master_node_name=$(cat conf/spark-cluster.info |grep MASTER_NODE_NAME| cut -d "=" -f 2)
workers=$(cat conf/spark-cluster.info | grep WORKER_NODE |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')
nodes=$(cat conf/spark-cluster.info |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'| sort -u)

rm -frv conf/*

# SPARK_MASTER_HOST	Bind the master to a specific hostname or IP address, for example a public one.
# SPARK_MASTER_PORT	Start the master on a different port (default: 7077).
# SPARK_MASTER_WEBUI_PORT	Port for the master web UI (default: 8080).
# SPARK_MASTER_OPTS	Configuration properties that apply only to the master in the form "-Dx=y" (default: none). See below for a list of possible options.
# SPARK_LOCAL_DIRS	Directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk. This should be on a fast, local disk in your system. It can also be a comma-separated list of multiple directories on different disks.
# SPARK_WORKER_CORES	Total number of cores to allow Spark applications to use on the machine (default: all available cores).
# SPARK_WORKER_MEMORY	Total amount of memory to allow Spark applications to use on the machine, e.g. 1000m, 2g (default: total memory minus 1 GB); note that each application's individual memory is configured using its spark.executor.memory property.
# SPARK_WORKER_PORT	Start the Spark worker on a specific port (default: random).
# SPARK_WORKER_WEBUI_PORT	Port for the worker web UI (default: 8081).
# SPARK_WORKER_DIR	Directory to run applications in, which will include both logs and scratch space (default: SPARK_HOME/work).
# SPARK_WORKER_OPTS	Configuration properties that apply only to the worker in the form "-Dx=y" (default: none). See below for a list of possible options.
# SPARK_DAEMON_MEMORY	Memory to allocate to the Spark master and worker daemons themselves (default: 1g).
# SPARK_DAEMON_JAVA_OPTS	JVM options for the Spark master and worker daemons themselves in the form "-Dx=y" (default: none).
# SPARK_DAEMON_CLASSPATH	Classpath for the Spark master and worker daemons themselves (default: none).
# SPARK_PUBLIC_DNS	The public DNS name of the Spark master and workers (default: none).

spark_dirs=()
spark_data_dir="/tmp/spark/data"
read -e -p "Specify spark-cluster data directory: " -i "$spark_data_dir" spark_data_dir
spark_work_dir="/tmp/spark/work"
read -e -p "Specify spark-cluster work directory: " -i "$spark_work_dir" spark_work_dir
spark_checkpoint_dir="/tmp/spark/checkpoint"
read -e -p "Specify spark-cluster work directory: " -i "$spark_checkpoint_dir" spark_checkpoint_dir
spark_logs_dir="$SPARK_HOME/logs"
read -e -p "Specify spark logs directory: " -i "$spark_logs_dir" spark_logs_dir

spark_worker_instances="2"
read -e -p "Specify spark-cluster worker instances per node: " -i "$spark_worker_instances" spark_worker_instances
spark_daemon_memory="1g"
read -e -p "Specify Memory to allocate to the Spark master and worker daemons themselves: " -i "$spark_daemon_memory" spark_daemon_memory
spark_worker_memory="2g"
read -e -p "Specify Total amount of memory to allow Spark applications to use on each node: " -i "$spark_worker_memory" spark_worker_memory

spark_master_ports=()
spark_master_port="7077"
read -e -p "Specify Port for the master: " -i "$spark_master_port" spark_master_port
spark_master_ports+=($spark_master_port)
spark_master_webui_port="9081"
read -e -p "Specify Port for the master web UI: " -i "$spark_master_webui_port" spark_master_webui_port
spark_master_ports+=($spark_master_webui_port)
# echo ${spark_master_ports[@]}

spark_worker_ports=()
spark_worker_webui_port="9082"
read -e -p "Specify Port for the worker web UI: " -i "$spark_worker_webui_port" spark_worker_webui_port
spark_worker_ports+=($spark_worker_webui_port)
# for each spark_worker ... add additional ports by incrementing the spark_worker_webui_port x the number of workers (less the one already added as the base)
max=$(( spark_worker_instances - 1 ))
port=$spark_worker_webui_port
for i in `eval echo {1..$max}`; do
  (( port = port + 1))
  spark_worker_ports+=($port)
done
# echo ${spark_worker_ports[@]}


# all nodes
cp -fv $SPARK_HOME/conf/spark-env.sh.template conf/spark-env.sh
cat <<EOF >conf/spark-env.sh
SPARK_DAEMON_MEMORY=$spark_daemon_memory
SPARK_WORKER_INSTANCES=$spark_worker_instances_per_node
SPARK_HOME=$SPARK_HOME
SPARK_LOCAL_DIRS=$spark_data_dir
SPARK_WORKER_MEMORY=$spark_worker_memory
SPARK_WORKER_WEBUI_PORT=$spark_worker_webui_port
SPARK_WORKER_DIR=$spark_work_dir
SPARK_MASTER_HOST=$master_node_name
SPARK_MASTER_PORT=$spark_master_port
SPARK_MASTER_WEBUI_PORT=$spark_master_webui_port
EOF
chmod +x conf/spark-env.sh

# master node
cp -fv $SPARK_HOME/conf/slaves.template conf/slaves
for each in $workers; do
  echo "$each" >> conf/slaves
done

cp -fv $SPARK_HOME/conf/spark-defaults.conf.template conf/spark-defaults.conf
cat <<EOF >conf/spark-defaults.conf
spark.master spark://$master_node_ip:$spark_master_port
EOF

touch conf/create_spark_dirs.sh
chmod +x conf/create_spark_dirs.sh
cat <<EOF >conf/create_spark_dirs.sh
# all nodes
if [ ! -d $spark_data_dir ]; then
  mkdir -pv $spark_data_dir && chmod ugo+w $spark_data_dir
fi

# all nodes
if [ ! -d $spark_work_dir ]; then
  mkdir -pv $spark_work_dir && chmod ugo+w $spark_work_dir
fi

# all nodes
if [ ! -d $spark_checkpoint_dir ]; then
  mkdir -pv $spark_checkpoint_dir && chmod ugo+w $spark_checkpoint_dir
fi

# spark needs a logs directory
if [ ! -d "$spark_logs_dir" ]; then
  mkdir -pv "$spark_logs_dir" && chmod ugo+rw "$spark_logs_dir"
fi

echo "export \$SPARK_CHECKPOINT_DIR=$spark_checkpoint_dir" >> /etc/profile.d/spark.sh
echo "export \$SPARK_WORK_DIR=$spark_work_dir" >> /etc/profile.d/spark.sh
echo "export \$SPARK_DATA_DIR=$spark_data_dir" >> /etc/profile.d/spark.sh
echo "export \$SPARK_LOGS_DIR=$spark_logs_dir" >> /etc/profile.d/spark.sh

EOF

# copy configs to all nodes in the cluster
for node in $nodes; do
  spark_installed=$(ssh $node 'if [ ! -z $SPARK_HOME ] && [ -d $SPARK_HOME/conf ]; then echo "y"; fi')
  if [ "$spark_installed" != "y"]; then
    echo -e "Spark doesn't seem to be installed on $node at $SPARK_HOME."
  else
    spark_conf_dir=$SPARK_HOME/conf
    scp -v conf/* $node:$spark_conf_dir
    if [ $? -eq 0 ]; then
      echo -e "Successfully copied configs to $node."
      ssh $node '$SPARK_HOME/conf/create_spark_dirs.sh'
    else
      echo -e "Something went wrong trying to copy configs to $node."
    fi
  fi
done

read -n 1 -s -r -p "Warning about to change firewwall rules on cluster machines. Press any key to continue..."
firewall-cmd --version
if [ $? -ne 0 ]; then
  echo -e "firewalld doesn't seem to be installed or running, skipping firewall configuration."
else
  for node in $nodes; do
    for port in "${spark_worker_ports[@]}"; do
      ssh $node "firewall-cmd --zone=public --permanent --add-port=$port/tcp" # one ui port for each worker
    done
  done
  for port in "${spark_master_ports[@]}"; do
    ssh $master_node_name "firewall-cmd --zone=public --permanent --add-port=$port/tcp" # master only
  done
fi
