# LOOKER STUDIO RDS INSTANCE

This is the RDS instance that holds the database for the Looker studio integration used for creating visualisations. It is created using a snapshot from the Marlowe Runtime RDS instance. Daily updates are done to it through a cron job configured on the bastion host (see below).

## COPYING DATA SNAPSHOT TO LOOKER DATABASE INSTANCE

There is a cron job on the bastion host that has been configured to run daily and update the looker studio RDS instance with the most recent snapshot from the Marlowe runtime RDS instance. The cron job uses terraform to do the update and the terraform configuration file can be found by viewing the cron job. 

To view the cronjob, ssh into the bastion host and run the below command:

```crontab -l```

To edit/update this cronjob (IF YOU ABSOLUTELY HAVE TO), run the below:

```crontab -e```
