# EXAMPLE: Deploying while managing DNS outside of AWS

## About This Example

This example contains a reference implementation for how to use this module to deploy Terraform Enterprise on AWS while managing DNS externally.

## What's different?

Whereas the main module uses a datasource to find your Route 53 hosted zone in order to automatically create an entry to your load balancer, this scenario assumes you are managing all DNS configuration. For this reason, you will need to use the provided output for the load balancer endpoint from the main module and configure that value wherever you are managing DNS.
