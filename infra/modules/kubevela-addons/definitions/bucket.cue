bucket: {
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
				locationConstraint: parameter.region
				if parameter.objectLockEnabledForBucket != _|_ {
					if parameter.objectLockEnabledForBucket {
						objectLockEnabledForBucket: parameter.objectLockEnabledForBucket
					}
				}
				objectOwnership: "BucketOwnerEnforced"
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
	outputs: {
		policy: {
			apiVersion: "iam.aws.crossplane.io/v1beta1"
			kind:       "Policy"
			metadata: name: parameter.bucketName
			spec: {
				if parameter.deletionPolicy != _|_ {
					deletionPolicy: parameter.deletionPolicy
				}
				forProvider: {
					description: "Allow application access to S3 bucket"
					name:        parameter.bucketName
					document:    """
						{
							"Version": "2012-10-17",
							"Statement": [
								{
									"Effect": "Allow",
									"Action": [
										"s3:*"
									],
									"Resource": [
										"arn:aws:s3:::\( parameter.bucketName )/*",
										"arn:aws:s3:::\( parameter.bucketName )"
									]
								},
								{
									"Effect": "Allow",
									"Action": "s3:ListAllMyBuckets",
									"Resource": "*"
								}
							]
						}
						"""
				}
				providerConfigRef: name: "aws-provider"
			}}
		role: {
			apiVersion: "iam.aws.crossplane.io/v1beta1"
			kind:       "Role"
			metadata: name: parameter.bucketName
			spec: {
				if parameter.deletionPolicy != _|_ {
					deletionPolicy: parameter.deletionPolicy
				}
				forProvider: {
					assumeRolePolicyDocument: """
						{
						  "Version": "2012-10-17",
						  "Statement": [
						    {
							  "Effect": "Allow",
							  "Principal": {
							  	"Federated": "arn:aws:iam::677160962006:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/CF3527C40042EA2A9E0A19B5C92CB4C9"
							  },
							  "Action": "sts:AssumeRoleWithWebIdentity"
							},
						    {
							  "Effect": "Allow",
							  "Principal": {
							  	"Federated": "arn:aws:iam::677160962006:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/06F13D0B65F521AA83C63A569CA21329"
							  },
							  "Action": "sts:AssumeRoleWithWebIdentity"
							}					
						  ]
						}
						"""
					tags: [{
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
					}, {
						key:   "bucketName"
						value: parameter.bucketName
					}]
				}
				providerConfigRef: name: "aws-provider"
			}}
		rolePolicyAttachment: {
			apiVersion: "iam.aws.crossplane.io/v1beta1"
			kind:       "RolePolicyAttachment"
			metadata: name: parameter.bucketName
			spec: {
				if parameter.deletionPolicy != _|_ {
					deletionPolicy: parameter.deletionPolicy
				}
				forProvider: {
					policyArnRef: name: parameter.bucketName
					roleNameRef: name: parameter.bucketName
				}
				providerConfigRef: name: "aws-provider"
			}

		}
	}
	parameter: {
		bucketName: string
		region:     *"us-east-1" | string
		// +usage=Enable Accelerate Configuration?
		accelerateConfiguration?: *false | bool
		// +usage=Enable Object Locking?
		objectLockEnabledForBucket?: *false | bool
		// +usage=Enable Public Access Block Configuration?
		publicAccessBlockConfiguration?: *true | bool
		// +usage=Enable Versioning Configuration?
		versioningConfiguration?: *false | bool
		// +usage=Specify a deletionPolicy. If 'Orphan' this component will not delete the external resource.
		deletionPolicy?: *"Delete" | "Oprhan"
	}
}

