"aws-s3": {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "s3.aws.crossplane.io/v1beta1"
		kind:       "Bucket"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "s3.aws.crossplane.io/v1beta1"
		kind:       "Bucket"
		metadata: name: parameter.name
		spec: {
			deletionPolicy: "Delete"
			forProvider: {
				if parameter.accelerateConfiguration != _|_ {
				  if parameter.accelerateConfiguration {
				    accelerateConfiguration: status: "Enabled"
				  }
				}
				locationConstraint: parameter.region
				if parameter.objectLockEnabled != _|_  {
				  if parameter.objectLockEnabledForBucket {
				    objectLockEnabledForBucket: parameter.objectLockEnabledForBucket
				  }
				}
				objectOwnership:            "BucketOwnerEnforced"
				if parameter.publicAccessBlock != _|_ {
				  if parameter.publicAccessBlock {
				    publicAccessBlockConfiguration: blockPublicPolicy: parameter.publicAccessBlock
				  }
				}
				serverSideEncryptionConfiguration: rules: [{
					applyServerSideEncryptionByDefault: sseAlgorithm: "AES256"
				}]
				tagging: tagSet: [{
					key:  "Project"
					value: "scde"
				}, {
					key:  "Tribe"
					value: "smartcontracts"
				}, {
					key:  "Organization"
					value: "iog"
				}, {
					key:  "managedBy"
					value: "kubeVela"
				}]
				if parameter.versioningConfiguration != _|_  {
				  if parameter.versioningConfiguration {
					versioningConfiguration: status: "Enabled"
				  }
				}
			}
			providerConfigRef: name: "aws-provider"
		}
	}
	outputs: {}
	parameter: {
	  name: string
	  region: *"us-east-1" | string
	  accelerateConfiguration?: *false | bool
	  objectLockEnabledForBucket?: *false | bool
	  publicAccessBlock?: *true | bool
	  versioningConfiguration?: *false | bool
	}
}
