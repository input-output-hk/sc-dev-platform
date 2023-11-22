outputs: {
	
	_tags: [
		{
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
			key:   "Application"
			value: context.appName
		},
	]

	if parameter.allocateDatabase != _|_ {
		db_parameter_group: {
			apiVersion: "rds.aws.crossplane.io/v1alpha1"
			kind:       "DBParameterGroup"
			metadata: name: "dbpg-\( parameter.name )"
			spec: {
				forProvider: {
					dbParameterGroupFamilySelector: engine: "postgres"
					description: "Parameter group for \( parameter.name ) RDS Instance"
					if parameter.allocateDatabase.customParameters != _|_ {
						parameters: [
							for parameter in parameter.allocateDatabase.customParameters {
								{
									applyMethod:    parameter.applyMethod
									parameterName:  parameter.Name
									parameterValue: parameter.Value
								}
							},
						]
					}
					region: "${aws_region}"
					tags:   _tags
				}
				providerConfigRef: name: "aws-provider"
			}
		}

		db_instance: {
			apiVersion: "database.aws.crossplane.io/v1beta1"
			kind:       "RDSInstance"
			metadata: name: parameter.name
			spec: {
				forProvider: {
					allocatedStorage:    parameter.allocateDatabase.storage
					maxAllocatedStorage: parameter.allocateDatabase.storage * 3
					applyModificationsImmediately: true
					autoMinorVersionUpgrade: false
					if parameter.allocateDatabase.backupRetentionPeriod != _|_ {
						backupRetentionPeriod: parameter.allocateDatabase.backupRetentionPeriod
					}
					caCertificateIdentifier: "rds-ca-rsa2048-g1"
					copyTagsToSnapshot:      false
					if parameter.allocateDatabase.instanceClass != _|_ {
						dbInstanceClass: parameter.allocateDatabase.instanceClass
					}
					dbName:               "scdedb"
					dbParameterGroupName: "dbpg-\( parameter.name )"
					dbSubnetGroupName:    "${env}-subnet-group"
					if parameter.allocateDatabase.deletionProtection != _|_ {
						deletionProtection: parameter.allocateDatabase.deletionProtection
					}
					enableIAMDatabaseAuthentication: false
					enablePerformanceInsights:       true
					engine:                          "postgres"
					if parameter.allocateDatabase.engineVersion != _|_ {
						engineVersion: parameter.allocateDatabase.engineVersion
					}
					masterUsername: "postgres"
					if parameter.iops != _|_ {
						iops: parameter.iops
					}
					monitoringInterval: 60
					monitoringRoleArn:  "arn:aws:iam::${account_id}:role/rds-monitoring-role"
					multiAZ:            true
					if parameter.allocateDatabase.preferredBackupWindow != _|_ {
						preferredBackupWindow: parameter.allocateDatabase.preferredBackupWindow
					}
					if parameter.allocateDatabase.preferredMaintenanceWindow != _|_ {
						preferredMaintenanceWindow: parameter.allocateDatabase.preferredMaintenanceWindow
					}
					publiclyAccessible: false
					region:                          "${aws_region}"
					skipFinalSnapshotBeforeDeletion: true
					storageEncrypted:                true
					storageType:                     "gp3"
					vpcSecurityGroupIds: 			 [ %{ for sg in security_groups ~} "${sg}", %{ endfor ~}]
					tags: _tags
				}
				providerConfigRef: name: "aws-provider"
				writeConnectionSecretToRef: {
					name:      "conn-\( parameter.name )"
					namespace: context.namespace
				}
			}
		}
	}
}

patch: spec: template: spec: containers: [{
	// +patchKey=name
	env: [{
		name: "DB_USER"
		valueFrom: secretKeyRef: {
			key:  "username"
			name: "conn-\( parameter.name )"
		}
	}, {
		name: "DB_PASS"
		valueFrom: secretKeyRef: {
			key:  "password"
			name: "conn-\( parameter.name )"
		}
	}, {
		name: "DB_HOST"
		valueFrom: secretKeyRef: {
			key:  "endpoint"
			name: "conn-\( parameter.name )"
		}
	}, {
		name:  "DB_NAME"
		value: "scdedb"
	},
	]
}]

parameter: {
	// +usage=Specify a name for the RDS instance name.
	name: string
	// +usage=Does this trait allocate a database?
	allocateDatabase?: {
		// +usage=Define a instance class
		instanceClass: *"db.t3.medium" | "db.t3.large" | "db.m7g.large" | "db.m7g.xlarge" | "db.m7g.2xlarge" | "db.m7g.4xlarge"
		// +usage=Define the storage size (in Gigabytes)
		storage: *400 | int
		// +usage=Define a backup retention period. Backup is disabled if it's set to 0.
		backupRetentionPeriod?: *0 | int
		// +usage=Do we need to enable deletion protection?
		deletionProtection?: *false | bool
		// +usage=Define an IOPS configuration 
		iops?: *12000 | int
		// +usage=Define a preferred backup window 
		preferredBackupWindow?: *"07:20-07:50" | string
		// +usage=Define a preferred maintenance window
		preferredMaintenanceWindow?: *"sun:03:13-sun:06:43" | string
		// +usage=Set custom settings on DB Parameter Group
		customParameters?: [...{
			applyMethod: *"immediate" | "pending-reboot"
			Name:        string
			Value:       string
		}]
	}
}