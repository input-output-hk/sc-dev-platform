#!/usr/bin/env python3

import subprocess
import json
import time

# Defining namespaces where our applications lives in
namespaces = ["marlowe-staging", "marlowe-production", "dapps-certification-staging"]

# Defining source and target clusters
# Must be the same names configured on kubectl contexts
source_cluster = "scde-prod-us-east-1-green"
target_cluster = "scde-prod-us-east-1-green"

for namespace in namespaces:
    cmd = subprocess.check_output('kubectl --context ' + source_cluster + ' -n ' 
    + namespace + ' get application | egrep "(helm|kustomize)" | awk \'{ print $2 }\'', shell=True).splitlines()

    for application in cmd:
        app_name = str(application, encoding="utf-8")
        
        # Extracting output from current applications
        output = json.loads(subprocess.check_output('kubectl --context ' + source_cluster + ' -n '
        + namespace + ' get application ' + app_name + ' -o json', shell=True))

        # Deleting some fields that we don't need 
        try:
            del output['metadata']['annotations'] 
            del output['metadata']['creationTimestamp']
            del output['metadata']['generation']
            del output['metadata']['finalizers'] 
            del output['metadata']['labels']
            del output['metadata']['resourceVersion']
            del output['metadata']['uid']
            del output['status']
        except:
            pass
        
        # Outputing files
        file_name = app_name+'.json'
        with open(file_name, 'w', encoding="utf-8") as file:
            json.dump(output, file, ensure_ascii=False, indent=4)

        # Importing the outputs on the target cluster        
        # print("Importing "+file_name) 
        # subprocess.check_output('kubectl --context ' + target_cluster + ' apply -f '+ file_name, shell=True)
        # time.sleep(5)
