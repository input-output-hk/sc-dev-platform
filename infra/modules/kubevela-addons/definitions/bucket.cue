import "encoding/json"

output: {
	apiVersion: "s3.aws.crossplane.io/v1beta1"
	kind:       "Bucket"
	metadata: name: context.appName
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

outputs: {
	_bucketPolicyDocument: {
		"Version": "2012-10-17",
		"Statement": [{
			"Effect": "Allow",
			"Action": [
				"s3:Get*",
				"s3:List*",
				"s3:Delete*",
				"s3:Put*",
			],
			"Resource": "arn:aws:s3:::\( context.appName )"
		}, {
			"Effect": "Allow", 
			"Action": "s3:List*",
			"Resource": "arn:aws:s3:::\( context.appName )"
		}]
	}

	_rolePolicyDocument: {
		"Version": "2012-10-17",
		"Statement": [{
			"Effect": "Allow",
			"Principal": { "Federated": "arn:aws:iam::${account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/CF3527C40042EA2A9E0A19B5C92CB4C9" },
			"Action": "sts:AssumeRoleWithWebIdentity"
		},{
			"Effect": "Allow",
			"Principal": { "Federated": "arn:aws:iam::${account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/06F13D0B65F521AA83C63A569CA21329" },
			"Action": "sts:AssumeRoleWithWebIdentity"
		}]
	}

	policy: {
		apiVersion: "iam.aws.crossplane.io/v1beta1"
		kind:       "Policy"
		metadata: name: "pol-\( context.appName )"
		spec: {
			forProvider: {
				description: "Allow application access to S3 buckets"
				name:        context.appName
				document: json.Marshal(_bucketPolicyDocument)
			}
			providerConfigRef: name: "aws-provider"
		}}

	role: {
		apiVersion: "iam.aws.crossplane.io/v1beta1"
		kind:       "Role"
		metadata: name: "role-\( context.appName )"
		spec: {
			forProvider: {
				assumeRolePolicyDocument: json.Marshal(_rolePolicyDocument)
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
					key:   "applicationName"
					value: context.appName
				}, {
					key:   "Env"
					value: "${env}"
				}]
			}
			providerConfigRef: name: "aws-provider"
		}}

	rolePolicyAttachment: {
		apiVersion: "iam.aws.crossplane.io/v1beta1"
		kind:       "RolePolicyAttachment"
		metadata: name: "role-pol-\( context.appName )"
		spec: {
			forProvider: {
				policyArnRef: name: "pol-\( context.appName )"
				roleNameRef: name:  "role-\( context.appName )"
			}
			providerConfigRef: name: "aws-provider"
		}}
}

parameter: {}