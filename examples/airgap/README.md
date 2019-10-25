## Terraform Enterprise Airgap Example

This example shows using the external-services module along with a the main
module to deploy TFE using external services using an airgap package.

This example uses a setup bucket that has been previously created and is
populated with the following items:

* tfe-setup/ptfe.zip mirrored https://install.terraform.io/installer/ptfe.zip with ACL **public-read**. **NOTE** This file must have a public-read ACL configured so it can be downloaded directly via http.
* tfe-setup/replicated.tar.gz mirriored from https://s3.amazonaws.com/replicated-airgap-work/replicated\_\_docker\_\_kubernetes.tar.gz with ACL **private**
* tfe-setup/v201911-1.airgap has been uploaded from the replicated.com portal. This contains the release we are deploying.
