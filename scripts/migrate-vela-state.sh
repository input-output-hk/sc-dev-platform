#!/bin/bash

if [ -z $1 ] | [ -z $2 ]; then
    echo "ERROR: You have to declare the source and target clusters."
    exit 1
fi

SOURCE_CLUSTER=$1
TARGET_CLUSTER=$2

[ -f migration.yaml ] && rm -f migration.yaml

# Extracting Dex users
 kubectl --context $SOURCE_CLUSTER -n kubevela get cm -oname  | egrep "^configmap/usr-chu" \
 | while read -r usr; do kubectl --context $SOURCE_CLUSTER -n kubevela get $usr -o yaml \
 | gsed "/creationTimestamp\|resourceVersion\|uid/d"; echo "---";  done \
 | tee -a migration.yaml

# Extracting projects and permissions
 kubectl --context $SOURCE_CLUSTER -n kubevela get cm -oname  | egrep ".*(pj|perm|role|pusr)" \
 | while read -r cm; do kubectl --context $SOURCE_CLUSTER -n kubevela get $cm -o yaml \
 | gsed "/creationTimestamp\|resourceVersion\|uid/d"; echo "---";  done \
 | tee -a migration.yaml

# Extracting environments and targets
 kubectl --context $SOURCE_CLUSTER -n kubevela get cm -oname  | egrep ".*/(ev|tg)-" | egrep -v ".*(syc|system|default)" \
 | while read -r cm; do kubectl --context $SOURCE_CLUSTER -n kubevela get $cm -o yaml \
 | gsed "/creationTimestamp\|resourceVersion\|uid/d"; echo "---";  done \
 | tee -a migration.yaml

# Extracting configs/secrets
# Don't know yet how to migrate config distributions, so we still have to create them manually :( 
kubectl --context $SOURCE_CLUSTER get secret -A -l config.oam.dev/catalog=velacore-config \
--no-headers | awk '{print $1,$2}' | while read ns secret; do \
 kubectl --context $SOURCE_CLUSTER -n $ns get secret $secret -oyaml \
 | gsed "/creationTimestamp\|resourceVersion\|uid/d"; echo "---"; done \
 | tee -a migration.yaml

# Creating namespaces
kubectl --context $SOURCE_CLUSTER -n kubevela get cm -oname | grep ".*/ev-" \
 | egrep -v "(default|system)" | sed "s/configmap\/ev-//g" \
 | while read -r namespace; do kubectl --context $TARGET_CLUSTER create ns $namespace; done

# Importing everything on the new cluster
kubectl --context $TARGET_CLUSTER apply -f migration.yaml
