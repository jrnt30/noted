# Overview & Goals
This was an attempt to emulate a small subset of functionality of a bookmarking tool in Lambda using Apex.

The main goal of this is to learn some of the tooling and functionality around Lambda rather than produce of "significant and lasting value".  Take that for what it is meant to be, a warning!

Currently the platform does work for limited scope:
- Allows users to log in with Auth0 with the Chrome extension
- Enables sharing of links via Slack with your friends or co-workers
- Sends a digest of "Noted" links at the end of the day

## Roadmap
- Automated Custom Domain & R53 management support
- Create alternate implementation in SAM CLI, Serverless, etc.
- Additional lambda to compile the digest of new links to registered users
- Categorization of links along with user preference management for notifications

# Project Customization
There have been some simplifying assumption about this project, specifically as it relates to the Auth0, Domain and S3 bucket structure.  To setup something full from scratch requires a few manual steps.

## Tooling
This project assumes you have a few tools installed.
- https://github.com/apex/apex
- http://github.com/hashicorp/terraform/
- https://www.npmjs.com/get-npm
- Go

## APEX Deployment
### AWS Account Setup
- Setup an s3 bucket that will serve as your Terraform remote state repository
- Update the `infrastructure` folder and replace all of the references to `dev-noted-apex` with the name of your S3 bucket
- Deploy the `apex` stack to create your account specific IAM roles to associate with the Apex functions
  - `make deploy-terraform-apex`
- Update the `project.json` to correct the AWS Account ID ID referenced in the default IAM role (ex: arn:aws:iam::11223311123:policy/lambda-log-access)

### Deploy the app
- Customize the necessary configuration settings for deployment:
  - `functions/notifier/function.json` - Update the Slack Token and Channel settings (NOTE: need to integrate something like SOPS w/ the Function Hooks in the future here to properly encrypt/decrypt these)
- Deploy the Functions
  - `apex deploy`
- Deploy the API Gateway and other configuration
  - `apex infra init`
  - `apex infra apply`

### Manual R53 & Stage setup
I just haven't gotten around to do this via TF yet, but that would be possible.
- Create a R53 DNS Hosted Zone or bring your own
- Create an [ACM Certificate](https://console.aws.amazon.com/acm/home?region=us-east-1) that will be used for your API Gateway Custom Domain
- Create a [Custom Domain](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html?icmpid=docs_apigateway_console) for your API Gateway & associate it with your `Deployment`
- Create a Route54 CNAME entry to map your `Custom Domain Name` with your `Target Domain Name`

NOTE: You're pretty much there.  There are some Auth0 specific configuration settings in the `project.json` specifically for Auth0 that need to be overwritten after we setup Auth0, but the functions, API Gateway and R53 entries are now in place.

### Local Development
In order to get this working, there are a few manual steps that need to be made.
- `make local-chrome-extension` --  Install the `chrome-extension` dependencies
- [Load the Chrome Extension](https://developer.chrome.com/extensions/getstarted#unpacked) and take note of the `ID`
- Create an Auth0 Native extension for Chrome
  - Create Auth0 Account
  - Application -> Create Application -> Native -> Chrome
    - `Allowed Callback URLs`: `https://<YOUR CHROME EXTENSION ID>.chromiumapp.org/auth0`
    - `Allowed Origins (CORS)`: `chrome://<YOUR CHROME EXTENSION ID>`
- Update the `chrome-extensions/env.js` with the DNS and Auth0 information for your environment
  - All the things
- Update the Apex `project.json` with your Auth0 settings
  - `environment.AUTH0_DOMAIN`
  - `environment.AUTH0_AUDIENCE`
- Redeploy the Auth0 authorizer for your Auth0 account
  - `apex deploy auth0authorizer`
- Test your extension!

# Open Questions
## General
- Any way to integrate something like `aws-local` with this?
- Any other tools that can use TF instead of CFN but have a better local development flow?
- What would be a good way of splitting out a project for a team?
- How to deal with encrypted vars?
  - https://github.com/apex/apex/issues/651
- Would it be worth it to create a lambda in the parent account that automatically creates a R53 hosted zone and delegates DNS to it when it sees a sub-org be added?

## Authentication
- What are the dimensions of the caching that occur?
  - Can I use a cached policy x-lambda or is the cache specific to it?
    - Does it take Headers into account?  Can I have a NIL Bearer header for unauth users and TOK for auth'd users work with one authorizer without them conflicting?
    - Does it take into consideration any of the path of the user?
      - What is the best way to build out a comprehensive graph of the API endpoints if not?
  - Is there a way to mutate the request or redirect based upon attributes (logged in vs. logged out), admin vs. user, etc.?
- Is a redirect or re-routing possible here?
- What are the dimensions of the `context` that we could leverage for customization?  Are these cached?


# Issues
- Role assumption I can't get working properly with Apex.  Tried updating the AWS SDK to get a fix, but even setting the `AWS_SDK_LOAD_CONFIG=true`, setting an explicit `AWS_REGION` and `AWS_PROFILE` I still am having issues with some of the commands.
