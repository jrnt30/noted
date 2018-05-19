# Overview
This was an attempt to emulate a small subset of functionality of a bookmarking tool in Lambda using Apex.

The project has lingered and not gotten much attention meanwhile the landscape has changed.  Worth considering using something else in the future.

# Roadmap
- Tie in user management/authentication with Auth0 & persist data
- New Chrome extension that uses Auth0 oauth to enable login/signup flow
- Additional lambda to compile and send "new" links to registered users
.
.
.
- Introduction of "Interests" concept (DevOps, Javascript, Cooking, etc.)
- Integration with classifier to guesstimate Link's associated "Interests"
- Query API

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