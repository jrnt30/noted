# Overview & Goals
This was an attempt to emulate a small subset of functionality of a bookmarking tool in Lambda.  After initially writing this in Apex I have decided to use this as a simple evaluation harness for some of the alternate Lambda compatible deployment frameworks now that Go is natively supported.

The pattern I am assuming we will be able to use is a set of handlers (functions/) that will be usable across the various Lambda enabled platforms.

The main goal of this is to learn some of the tooling and functionality around Lambda rather than produce of "significant and lasting value".  Take that for what it is meant to be, a warning!

Currently the Apex implementation implements:
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

# Open Questions
## General
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
