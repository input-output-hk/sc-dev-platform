"bucket-user": {
	alias: ""
	annotations: {}
	attributes: {
		appliesToWorkloads: ["deployments.apps", "statefulsets.apps", "daemonsets.apps", "jobs.batch"]
		conflictsWith: []
		podDisruptive:   true
		workloadRefPath: ""
	}
	description: "Allow an Application to use S3 Buckets"
	labels: {}
	type: "trait"
}

template: {
	patch: spec: template: spec: {
		serviceAccount: context.name
		serviceAccountName: context.name
	}
	outputs: serviceAccount: {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {
			annotations: "eks.amazonaws.com/role-arn": "arn:aws:iam::677160962006:role/\( parameter.bucketName )"
			name: context.name
		}
	}
	parameter: {
	  bucketName: string
	}
}
