import "encoding/json"

patch: spec: template: spec: {
	serviceAccount:     context.name
	serviceAccountName: context.name
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
			"Resource": [ for bucket in parameter.bucketNames {
				"arn:aws:s3:::\( bucket )\/*",				
			}]
		}, {
			"Effect": "Allow", 
			"Action": "s3:List*",
			"Resource": [ for bucket in parameter.bucketNames {
				"arn:aws:s3:::\( bucket )",
			}]
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
		metadata: name: context.name
		spec: {
			forProvider: {
				description: "Allow application access to S3 buckets"
				name:        context.name
				document: json.Marshal(_bucketPolicyDocument)
			}
			providerConfigRef: name: "aws-provider"
		}}

	role: {
		apiVersion: "iam.aws.crossplane.io/v1beta1"
		kind:       "Role"
		metadata: name: context.name
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
					value: context.name
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
		metadata: name: context.name
		spec: {
			forProvider: {
				policyArnRef: name: context.name
				roleNameRef: name:  context.name
			}
			providerConfigRef: name: "aws-provider"
		}}

	serviceAccount: {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {
			annotations: "eks.amazonaws.com/role-arn": "arn:aws:iam::${account_id}:role/\( context.name )"
			name: context.name
		}}
}
parameter: {
	// +usage=Specify a list of bucket names that will be used in this application
	bucketNames: [...string]
}