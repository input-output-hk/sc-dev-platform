import "encoding/json"

patch: spec: template: spec: {
	serviceAccount:     context.name
	serviceAccountName: context.name
}

outputs: {

	serviceAccount: {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {
			annotations: "eks.amazonaws.com/role-arn": "arn:aws:iam::${account_id}:role/role-\( parameter.bucketName )"
			name: context.name
		}}

}

parameter: {
	// +usage=Specify a bucket name that will be used in this application
	bucketName: string
}