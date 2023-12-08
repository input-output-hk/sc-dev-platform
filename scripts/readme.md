### Update KUBECONFIG for EKS Cluster

**Description:**
This script automates the process of updating the KUBECONFIG file for an Amazon EKS cluster. It dynamically fetches the EKS cluster name from Terraform and provides options to either update the existing context or delete it. The script ensures a seamless experience for managing Kubernetes configurations.

**Use Case:**

- Updating KUBECONFIG for EKS clusters
- Simplifying context management in Kubernetes deployments

**Dependencies:**

- Terraform for infrastructure management
- AWS CLI for EKS cluster operations
- kubectl for Kubernetes configuration

**Usage**
`./update-nix-kube-config.sh <env> <cluster>`

---

### Namespace Application Migration Script

**Description:**
This Python script automates the migration of applications between Kubernetes clusters within specified namespaces. It extracts application configurations from the source cluster, removes unnecessary fields, and imports the modified configurations into the target cluster. The script is designed to handle both Helm and Kustomize-based applications, providing a streamlined migration process.

**Use Case:**

- Migrating applications between Kubernetes clusters.
- Streamlining application management within targeted namespaces.

**Script Features:**

- **Namespace Selection:**

  - Targets applications within specified namespaces (e.g., "marlowe-staging," "marlowe-production," "dapps-certification-staging").

- **Source and Target Clusters:**

  - Migrates applications from a defined source cluster (e.g., "scde-prod-blue") to a target cluster (e.g., "scde-prod-green").

- **Configuration Extraction and Transformation:**

  - Extracts application configurations using kubectl commands.
  - Removes unnecessary fields (e.g., annotations, timestamps, labels) for a cleaner migration.

- **Output Files:**

  - Outputs individual JSON files for each migrated application, aiding inspection and tracking.

- **Import to Target Cluster:**

  - Imports modified application configurations into the target cluster using kubectl apply.

- **Delay Between Imports:**
  - Includes a time delay (5 seconds) between imports for a controlled migration process.

**Dependencies:**

- kubectl for Kubernetes cluster interaction.
- Python 3.11 or later.

**Usage**
`./migrate-applications.py`
