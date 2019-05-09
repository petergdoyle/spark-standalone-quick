#!/usr/bin/env bash


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
