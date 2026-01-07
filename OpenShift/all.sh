#!/bin/bash

# Recupera tutti i namespace
namespaces=$(oc get projects --short)

for ns in $namespaces; do
    # Recupera i dettagli di tutti i deployment
    deployments=$(oc get deployments -n "$ns" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.template.metadata.annotations.prometheus\.io/path}{" "}{.spec.template.metadata.annotations.prometheus\.io/port}{"\n"}{end}')

    while read -r name path port; do
        [ -z "$name" ] && continue
        
        path=${path:-"/metrics"}
        port=${port:-"8080"}

        # Trova il primo pod RUNNING associato al deployment
        pod_ip=$(oc get pods -n "$ns" -l "app=$name" -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
        
        if [ -z "$pod_ip" ]; then
            echo "Namespace: $ns , Deployment: $name , Stato: Nessun Pod trovato"
            continue
        fi

        # Esegue la curl tramite il router
        metrics=$(oc exec -n default $(oc get pods -n default -l "ingresscontroller.operator.openshift.io/owning-ingresscontroller=default" -o name | head -n 1) -- curl -s http://"$pod_ip":"$port""$path" | grep -v "^#" | grep -v "^$" | wc -l)

        echo "Namespace: $ns , Deployment: $name , Metriche esposte: $metrics"
        
    done <<< "$deployments"
done