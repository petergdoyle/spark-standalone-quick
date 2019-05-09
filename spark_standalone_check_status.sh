#!/usr/bin/env bash
ps aux |egrep 'Worker|Master' |grep -v grep
