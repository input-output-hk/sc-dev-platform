# EKS architecture for wallet-world

The aim is to replicate all bitte stack on top of Kubernetes in EKS

## Processes

### Deployment

- Software packaged in Helm charts
  - TODO: investigate how to wrap it in Nix
- EKS and Helm releases defined in Terragrunt
- automated deployments with ArgoCD
  - could use GH Actions until we set that up

### Repos

- wallet-world will have the infrastructure and lace k8s deployments
- we should push to bring all development into wallet-world
- in case of seperate repos like dappstore - they should have their own credentials to OCI registry and k8s as well as be self sufficiant to build/deploy their services

### Access

- for operators
  - right now: custom users in obscure AWS org that Gytis creates if and when he wishes
  - aim: have set up like with Vault where Vault is configured to issue access credentials (AWS, Kubernetes, whatever) based on GitHub token
    - TODO: Gytis will ask David if we could just reuse same Vault
    - TODO: Investigate how we can move Vault to Kubernetes or use Teleport
- for devs, use Google OAuth for all services

## Services to deploy

- infrastructure services
  - ingress with Google OAuth and DNS integration
    - ELB ingress
    - teleport for OAuth
    - external-dns handles DNS to provide \*.lw.iog.io entries
  - monitoring
    - Prometheus, Loki and Grafana
  - key management to replace Vault
    - TODO: figure out how Secrets work (external?)
- lace environments (\*-prod,dev,nightly)
  - database
    - TODO: Investigate using RDS, possible downsides?
  - cardano-node
  - db-sync
  - ogmios
- dapp-store-frontend
- dapp-store microservices
  - oura
  - kafka
    - TODO: Investigate MKS
  - dapp-store-validation-service
  - dapp-store API
- architecture

## EKS namespaces:

- {preprod,preview,mainnet}-{prod,dev}
- {preprod,preview}-nightly
- lace-dev (like infra in nomad. Used for shared services between dev envs)

## cardano-stuff deployment:

- helm chart (may or may not be wrapped with terraform or nix)
- includes postgres
- includes db-sync
- includes ogmios
