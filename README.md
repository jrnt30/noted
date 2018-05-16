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

# Open Questions
- Any way to integrate something like `aws-local` with this?
- Any other tools that can use TF instead of CFN but have a better local development flow?
- What would be a good way of splitting out a project for a team?
- How to deal with encrypted vars?
  - https://github.com/apex/apex/issues/651
