# Overview
This was an attempt to emulate a small subset of functionality of a bookmarking tool in Lambda using AWS SAM CLI.


# SAM notes:
- Discovers your local AWS configuration and will inject those credentials into the Lambda execution environment so things like `session.New` in your handler code "just work".  Very handy!
- Supports `cookiecutter` templates for projects out of the box, this could be useful for creating a set of common, reusable projects for different clients
- Uses CFN which generally I'm meh about
  - Does provide an easier path of integration that the Apex model.
    - In general I found the Terraform configuration somewhat verbose for the Serverless stuff.
    - The nesting of policies and what not in SAM I think makes it a bit less accessible for reusability.
    - Will need to see how things like Anchors work for reuse with SAM
