
# run helm install
# get external IP from service and set variable
helm install atlantis runatlantis/atlantis -f values.yaml

ATLANTIS_HOST=$(kubectl get svc -n default atlantis -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

atlantis server --gh-user fake --gh-token fake --repo-allowlist 'github.com/input-output-hk/*' --atlantis-url http://$ATLANTIS_HOST

atlantis server --gh-app-id '792449' --gh-app-key-file atlantis-app-key.pem --gh-webhook-secret a23a0a7c3df65bd6847ca5aa446d6063f6f4293c --write-git-creds --repo-allowlist 'github.com/input-output-hk/*' --atlantis-url https://$ATLANTIS_HOST
