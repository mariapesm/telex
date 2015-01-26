# 𝕋𝔼𝕃𝔼𝕏

[![Build Status](https://travis-ci.org/heroku/telex.svg)](https://travis-ci.org/heroku/telex)

![telex](docs/telex-cc-by-sa-jens-ohlig.jpg)

## Overview

A `Producer` is a component, team, person, etc that wants to send notifications to customers. It has its own set of credentials and name.

A producer can send a `Message` to 𝕋𝔼𝕃𝔼𝕏 through the API directly or a client such as [minitel](https://github.com/heroku/minitel). Producers can also send follow-up to existing messages.

A Message has a title, body and can target either an App or a single User. If it is an app, 𝕋𝔼𝕃𝔼𝕏 looks up the owner and all collaborators. If it's a user, it just looks up the user.

The message is then plexed to potentially several `Notifications` for each user. This sends an email to the user, and the notification will show up in the user's `/user/notifications/` endpoint on 𝕋𝔼𝕃𝔼𝕏. Users can access this with a Heroku oauth token or through services such as <https://dashboard.heroku.com>.


## Setup

To run locally:

```
$ bin/setup
```

To deploy to the platform:

```
h addons:add hpg:s0
h pg:promote <that database>
h addons:add mailgun
h addons:add redisgreen
h addons:add pgbackups:auto-month
h config:add REDIS_PROVIDER=REDISGREEN_URL
h config:set API_KEY_HMAC_SECRET=$(dd if=/dev/urandom bs=127 count=1 2>/dev/null | openssl base64 -A)
h config:set HEROKU_API_URL=https://telex:<key>@api.heroku.com

git push heroku master
h run rake db:migrate
```

## Operations

Refer to [our internal guide on Telex](https://github.com/heroku/engineering-docs/blob/master/components/telex/README.md)
