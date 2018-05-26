# Overview
This was an attempt to emulate a small subset of functionality of a bookmarking tool in Lambda using AWS SAM CLI.

# Useful Links
- [Custom Authorizers](https://bryson3gps.wordpress.com/2018/01/29/building-aws-serverless-applications-part-2/)

# Issues
- [Templating out inline swagger](https://github.com/awslabs/serverless-application-model/issues/203)

# SAM notes:
- Discovers your local AWS configuration and will inject those credentials into the Lambda execution environment so things like `session.New` in your handler code "just work".  Very handy!
- Supports `cookiecutter` templates for projects out of the box, this could be useful for creating a set of common, reusable projects for different clients
- Uses CFN which generally I'm meh about
  - Does provide an easier path of integration that the Apex model.
    - In general I found the Terraform configuration somewhat verbose for the Serverless stuff.
    - The nesting of policies and what not in SAM I think makes it a bit less accessible for reusability.
    - Will need to see how things like Anchors work for reuse with SAM
  - I find the discoverability of the documentation somewhat lacking.  Trying to understand what is possible took several passes and a bulk of the learning was via blog posts.  I find the TF docs to be more intuitive to navigate by far.
  - CFN doesn't reconcile state with reality properly.  If you delete or mutate a resource CFN doesn't validate that it is still present before proceeding.  This seems like fairly basic table stakes at this point and something I had taken for granted with TF
  - The feedback cycle for failures is really poor.  You have to go to the events of a stack and dig through all of the events until you uncover in the event log the thing that failed initially
  - Default is to still fully rollback stack on failure