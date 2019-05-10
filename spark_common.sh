#!/usr/bin/env bash

function define_cluster_nodes() {
  rm -fvr spark-cluster.info
  touch spark-cluster.info
  master_node_name='spark-master'
  master_node_ip=$(ifconfig |egrep 'inet ([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3})'| awk '{print $2}'| grep -v '127.0.0.1'|  head -n 1)
  read -e -p "[spark-cluster-quick] Enter the hostname for the master node: " -i "$master_node_name" master_node_name
  master_node_ip=$(ping -c 1 $master_node_name |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'| head -n 1)
  while [ "$master_node_ip" == "" ]; do
    read -e -p "[spark-cluster-quick] Cannot resolve master node specified as $master_node_name. Enter the ip for the master node: " -i "$master_node_ip" master_node_ip
    master_node_ip=$(ping -c 1 $master_node_ip |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'| head -n 1)
    if [ "$master_node_ip" != "" ]; then
      read -n 1 -s -r -p "'$master_node_ip $master_node_name' will be added to /etc/hosts. Press any key to continue..."
      # echo "$master_node_ip $master_node_name" >> /etc/hosts
      echo MASTER_NODE_NAME=$master_node_name >> spark-cluster.info
      echo MASTER_NODE_IP=$master_node_ip >> spark-cluster.info
      echo -e ""
    fi
  done
  worker_id=1
  worker_node_name="spark-worker-$worker_id"
  worker_node_ip="$master_node_ip"
  add_more=true
  while $add_more; do
    read -e -p "[spark-cluster-quick] Enter the hostname for worker node #$worker_id: " -i "$worker_node_name" worker_node_name
    worker_node_ip=$(ping -c 1 $worker_node_name |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'| head -n 1)
    while [ "$worker_node_ip" == "" ]; do
      read -e -p "[spark-cluster-quick] Cannot resolve worker node specified as $worker_node_name. Enter the ip for worker node #$worker_id: " -i "$worker_node_ip" worker_node_ip
      worker_node_ip=$(ping -c 1 $worker_node_ip |egrep -oh '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'| head -n 1)
      if [ "$worker_node_ip" != "" ]; then
        read -n 1 -s -r -p "'$worker_node_ip $worker_node_name' will be added to /etc/hosts. Press any key to continue"
        # echo "$worker_node_ip $worker_node_name" >> /etc/hosts
        echo WORKER_NODE_$worker_id"_NAME="$worker_node_name >> spark-cluster.info
        echo WORKER_NODE_$worker_id"_IP="$worker_node_ip >> spark-cluster.info
        echo ""
      fi
    done
    continue="y"
    read -e -p "[spark-cluster-quick] Add another worker node (y/n)?: " -i "$continue" continue
    if [ "$continue" != "y" ]; then
      add_more=false
    else
      add_more=true
      worker_id=$[$worker_id +1]
      worker_node_name="spark-worker-$worker_id"
    fi
  done
  cat spark-cluster.info
}

function spark_stop_master() {
    $SPARK_HOME/sbin/stop-master.sh
}

function spark_stop_slaves() {
    $SPARK_HOME/sbin/stop-slaves.sh
}

function spark_check_status() {
  ps aux |egrep 'Worker|Master' |grep -v grep
}

function spark_cleanup_runtime() {

  cmd="rm -frv $SPARK_HOME/logs/*"
  read -n 1 -s -r -p "About to delete contents under $SPARK_HOME/logs/ ! Press any key to continue"
  eval "$cmd"

  cmd="rm -fvr /tmp/spark/*/*"
  read -n 1 -s -r -p "About to delete contents under /tmp/spark/*/* ! Press any key to continue"
  eval "$cmd"

}

function open_firewall_ports() {

  # Standalone mode only
  # From	To	Default Port	Purpose	Configuration Setting	Notes
  # Browser	Standalone Master	8080	Web UI	spark.master.ui.port /
  # SPARK_MASTER_WEBUI_PORT	Jetty-based. Standalone mode only.
  # Browser	Standalone Worker	8081	Web UI	spark.worker.ui.port /
  # SPARK_WORKER_WEBUI_PORT	Jetty-based. Standalone mode only.
  # Driver /
  # Standalone Worker	Standalone Master	7077	Submit job to cluster /
  # Join cluster	SPARK_MASTER_PORT	Set to "0" to choose a port randomly. Standalone mode only.
  # External Service	Standalone Master	6066	Submit job to cluster via REST API	spark.master.rest.port	Use spark.master.rest.enabled to enable/disable this service. Standalone mode only.
  # Standalone Master	Standalone Worker	(random)	Schedule executors	SPARK_WORKER_PORT	Set to "0" to choose a port randomly. Standalone mode only.

  # All cluster managers
  # From	To	Default Port	Purpose	Configuration Setting	Notes
  # Browser	Application	4040	Web UI	spark.ui.port	Jetty-based
  # Browser	History Server	18080	Web UI	spark.history.ui.port	Jetty-based
  # Executor /
  # Standalone Master	Driver	(random)	Connect to application /
  # Notify executor state changes	spark.driver.port	Set to "0" to choose a port randomly.
  # Executor / Driver	Executor / Driver	(random)	Block Manager port	spark.blockManager.port	Raw socket via ServerSocketChannel

  firewall-cmd --zone=public --add-port=9082/tcp
  firewall-cmd --zone=public --add-port=9083/tcp # workers will start using ports from 9082 ...  9083, 9083... per worker
  firewall-cmd --zone=public --add-port=9081/tcp
  firewall-cmd --zone=public --add-port=6066/tcp
  firewall-cmd --zone=public --add-port=4040/tcp

  firewall-cmd --zone=public --add-port=7077/tcp # master only

}
