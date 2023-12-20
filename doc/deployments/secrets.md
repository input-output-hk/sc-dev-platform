# Secrets

## Adding secrets
Secrets can be added through the [web platform][scdev-vela]. Go to the `Projects` section (in left sidebar), click on your team's project, scroll down to the `Configs` section, and then click add. You can then set keys and values for whatever secret information you want to save.
The content of a secret cannot be viewed or changed after adding it, so to update a secret it must be deleted then re-created.

## Using secrets
To use a secret in a component, the data can be passed as environment variables. If you created a secret called `my-password` with the `passx` key containing a password and you wanted the password to be available to the container through the `$MYPASS` environment variable, you could add the following code under the `properties` section of the component.
```yaml
env:
 - name: MYPASS
   valueFrom:
     secretKeyRef:
       key: passx
       name: my-password
```
This can also be done through the [web ui][scdev-vela] by going to the advanced parameters of a component and adding an evironment variable with the `Add by secret` option. Keep in mind the dropdown menu won't detect the secret that was made, so the name and key will have to be manually typed into the two input boxes on the right.

[scdev-vela]: https://vela.scdev.aws.iohkdev.io
