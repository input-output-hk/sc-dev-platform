"bucket": {
	alias: ""
	annotations: {}
	attributes: workload: {
		definition: {
			apiVersion: "s3.aws.crossplane.io/v1beta1"
			kind:       "Bucket"
		}
		type: "buckets.s3.aws.crossplane.io"
	}
	description: "This component creates a s3 bucket on AWS using crossPlane"
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "s3.aws.crossplane.io/v1beta1"
		kind:       "Bucket"
		metadata: name: parameter.bucketName
		spec: {
            if parameter.deletionPolicy != _|_ {
              deletionPolicy: parameter.deletionPolicy
            }
			forProvider: {
                if parameter.accelerateConfiguration != _|_ {
                  if parameter.accelerateConfiguration {
				    accelerateConfiguration: status: "Enabled"
                  }
                }
				locationConstraint:         parameter.region
				if parameter.objectLockEnabledForBucket != _|_ {
                  if parameter.objectLockEnabledForBucket {
                    objectLockEnabledForBucket: parameter.objectLockEnabledForBucket
                  }
                }
				objectOwnership:            "BucketOwnerEnforced"
                if parameter.publicAccessBlockConfiguration != _|_ {
                  if parameter.publicAccessBlockConfiguration {
				    publicAccessBlockConfiguration: blockPublicPolicy: parameter.publicAccessBlockConfiguration
                  }
                }
				serverSideEncryptionConfiguration: rules: [{
					applyServerSideEncryptionByDefault: sseAlgorithm: "AES256"
				}]
				tagging: tagSet: [{
					key:   "Project"
					value: "scde"
				}, {
					key:   "Tribe"
					value: "smartcontracts"
				}, {
					key:   "Organization"
					value: "iog"
				}, {
					key:   "managedBy"
					value: "kubeVela"
				}]
                if parameter.versioningConfiguration != _|_ {
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
        bucketName: string
		region:                          *"us-east-1" | string
        // +usage=Enable Accelerate Configuration?
		accelerateConfiguration?:        *false | bool
        // +usage=Enable Object Locking?
		objectLockEnabledForBucket?:     *false | bool
        // +usage=Enable Public Access Block Configuration?
		publicAccessBlockConfiguration?: *true | bool
        // +usage=Enable Versioning Configuration?
		versioningConfiguration?:        *false | bool
        // +usage=Specify a deletionPolicy. If 'Orphan' this component will not delete the external resource.
		deletionPolicy?: *"Delete" | "Oprhan"
	}
}