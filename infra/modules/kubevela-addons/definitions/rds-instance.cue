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

	if parameter.createDatabase != _|_ {
		db_parameter_group: {
			apiVersion: "rds.aws.crossplane.io/v1alpha1"
			kind:       "DBParameterGroup"
			metadata: name: "dbpg-\( parameter.name )"
			spec: {
				forProvider: {
					dbParameterGroupFamilySelector: engine: "postgres"
					description: "Parameter group for \( parameter.name ) RDS Instance"
					if parameter.createDatabase.customParameters != _|_ {
						parameters: [
							for parameter in parameter.createDatabase.customParameters {
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
					allocatedStorage:    parameter.createDatabase.allocatedStorage
					maxAllocatedStorage: parameter.createDatabase.allocatedStorage * 3
					applyModificationsImmediately: true
					autoMinorVersionUpgrade: false
					if parameter.createDatabase.backupRetentionPeriod != _|_ {
						backupRetentionPeriod: parameter.createDatabase.backupRetentionPeriod
					}
					caCertificateIdentifier: "rds-ca-rsa2048-g1"
					copyTagsToSnapshot:      false
					if parameter.createDatabase.dbInstanceClass != _|_ {
						dbInstanceClass: parameter.createDatabase.dbInstanceClass
					}
					dbName:               parameter.dbName
					dbParameterGroupName: "dbpg-\( parameter.name )"
					dbSubnetGroupName:    "${env}-subnet-group"
					if parameter.createDatabase.deletionProtection != _|_ {
						deletionProtection: parameter.createDatabase.deletionProtection
					}
					enableIAMDatabaseAuthentication: false
					enablePerformanceInsights:       true
					engine:                          "postgres"
					if parameter.createDatabase.engineVersion != _|_ {
						engineVersion: parameter.createDatabase.engineVersion
					}
					masterUsername: "postgres"
					if parameter.iops != _|_ {
						iops: parameter.iops
					}
					monitoringInterval: 60
					monitoringRoleArn:  "arn:aws:iam::${account_id}:role/rds-monitoring-role"
					multiAZ:            true
					if parameter.createDatabase.preferredBackupWindow != _|_ {
						preferredBackupWindow: parameter.createDatabase.preferredBackupWindow
					}
					if parameter.createDatabase.preferredMaintenanceWindow != _|_ {
						preferredMaintenanceWindow: parameter.createDatabase.preferredMaintenanceWindow
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
		value: parameter.dbName
	},
	]
}]

parameter: {
	// +usage=Specify a name for the RDS instance name.
	name: string
	// +usage=Specify a Database name. If creating a new RDS instance with this trait, this database will be created automatically.
	dbName: string
	// +usage=Does this trait create a database?
	createDatabase?: {
		// +usage=Define a instance class
		dbInstanceClass: *"db.t3.medium" | "db.t3.large" | "db.m7g.large" | "db.m7g.xlarge" | "db.m7g.2xlarge" | "db.m7g.4xlarge"
		// +usage=Define the storage size
		allocatedStorage: *400 | int
		// +usage=Define a backup retention period. If will disable backups if is set to 0.
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