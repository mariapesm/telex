# 𝕋𝔼𝕃𝔼𝕏

[![Build Status](https://travis-ci.org/heroku/telex.svg)](https://travis-ci.org/heroku/telex)

![telex](docs/telex-cc-by-sa-jens-ohlig.jpg)

## Overview

To send messages through telex, you'll first need a `Producer`. A Producer is like an "Application Authorization", with a name and credentials. It can represent a component, team, person, etc that wants to send notifications to customers - or you can use a different on e for each type of message you send.

Using your Producer credentials, you can send a `Message` to 𝕋𝔼𝕃𝔼𝕏 through the API directly, or using a client such as [minitel](https://github.com/heroku/minitel).

A Message can target either an App or a User. If it's a user, it just looks up the user. If it is an app, 𝕋𝔼𝕃𝔼𝕏 looks up the owner and all collaborators and sends to each of those, without going through [premiumrush](https://github.com/heroku/premiumrush).

A Message has a `title` and a `body`. The body can have access to some variables such as `{{user}}` and `{{app}}`. It inserts these using a simple find-and-replace.

A Message can also be sent as a `followup` to an existing message, threading them in some places.

Both of these always happen, with the same message in both places:
- An email is sent to the user. 
- The notification shows up in Dashboard, using the telex endpoint `/user/notifications/`. This endpoint returns the most recent month's  Notifications.

Each message plexed to potentially several `Notifications` for each user. Telex does not de-dupe messages well.

## Example Usage

- [Logdrain Remediations](https://github.com/heroku/logdrain-remediation/blob/2fa6b0af6e8fef568dfddb2b70b5542960cf260a/lib/mediators/notifier.rb#L20-L25)
- [Godzilla](https://github.com/heroku/godzilla)

## Setup

To run locally:

```
$ bin/setup
```

To deploy to the platform:

```
h addons:create heroku-postgresql:standard-0
h pg:promote <that database>
h addons:create mailgun
h addons:create redisgreen
h addons:create pgbackups:auto-month
h config:add REDIS_PROVIDER=REDISGREEN_URL
h config:set API_KEY_HMAC_SECRET=$(dd if=/dev/urandom bs=127 count=1 2>/dev/null | openssl base64 -A)
h config:set HEROKU_API_URL=https://telex:<key>@api.heroku.com

git push heroku master
h run rake db:migrate
```

## Operations

Refer to [our internal guide on Telex](https://github.com/heroku/engineering-docs/blob/master/components/telex/README.md)
