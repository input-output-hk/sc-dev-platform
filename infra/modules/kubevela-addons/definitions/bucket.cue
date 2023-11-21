output: {
	apiVersion: "s3.aws.crossplane.io/v1beta1"
	kind:       "Bucket"
	metadata: name: parameter.bucketName
	spec: {
		forProvider: {
			locationConstraint: "${aws_region}"
			objectOwnership: "BucketOwnerEnforced"
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
			}, {
				key:   "Env"
				value: "${env}"
			}]
			versioningConfiguration: status: "Suspended"
		}
		providerConfigRef: name: "aws-provider"
	}
}

outputs: {}

parameter: {
	// +usage=Specify a bucket name
	bucketName: string
}
