# Deployment

## Setup

You'll need to clone the repo, then join and set git remotes for staging and production.

```
$ git clone git@github.com:heroku/telex.git
$ heroku apps:join -a telex-staging
$ heroku git:remote -a telex-staging -r staging
$ heroku apps:join -a telex
$ git:remote -a telex -r production
```

## Deploy to Staging:

```
$ git push staging master
```

## Test in Staging:

1. Create a new producer on staging or update the api key for an existing one https://github.com/heroku/engineering-docs/blob/master/components/telex/user-guide.md#create-a-new-producer
2. Then use https://github.com/heroku/minitel or curl to send a test message to an app you control, and see if the notification goes through.

## Deploy to Production:

```
$ git push production master
```
