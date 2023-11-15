"bucket-user": {
	alias: ""
	annotations: {}
	attributes: {
		appliesToWorkloads: ["deployments.apps", "statefulsets.apps", "daemonsets.apps", "jobs.batch"]
		podDisruptive:   true
		workloadRefPath: ""
	}
	description: "Allow an Application to use S3 Buckets"
	labels: {}
	type: "trait"
}

template: {
	patch: spec: template: spec: {
		serviceAccount:     context.name
		serviceAccountName: context.name
	}
	outputs: {
		policy: {
			apiVersion: "iam.aws.crossplane.io/v1beta1"
			kind:       "Policy"
			metadata: name: context.name
			spec: {
				if parameter.deletionPolicy != _|_ {
					deletionPolicy: parameter.deletionPolicy
				}
				forProvider: {
					description: "Allow application access to smartcontracts S3 buckets"
					name:        context.name
					document: """
						{
							"Version": "2012-10-17",
							"Statement": [
								{
									"Effect": "Allow",
									"Action": [
										"s3:Get*",
										"s3:List*",
										"s3:DeleteObject*",
										"s3:PutOBject*",
									],
									"Resource": [
										"arn:aws:s3:::sc-*/*",
										"arn:aws:s3:::sc-*"
									]
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
			metadata: name: context.name
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
						key:   "applicationName"
						value: context.name
					}]
				}
				providerConfigRef: name: "aws-provider"
			}}
		rolePolicyAttachment: {
			apiVersion: "iam.aws.crossplane.io/v1beta1"
			kind:       "RolePolicyAttachment"
			metadata: name: context.name
			spec: {
				if parameter.deletionPolicy != _|_ {
					deletionPolicy: parameter.deletionPolicy
				}
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
				annotations: "eks.amazonaws.com/role-arn": "arn:aws:iam::677160962006:role/\( context.name )"
				name: context.name
			}}
	}
	parameter: {}
}

