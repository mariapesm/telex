## API Docs

```bash
export URL=https://telex-opex.herokuapp.com
export APP=dcca932b-0156-4d11-b5fd-fcec4c924be2
export TOKEN=$(heroku auth:token)
```

### Create Recipient

#### Request

```bash
curl -XPOST $URL/apps/$APP/recipients \
	-u :$TOKEN \
	-d '{"email":"some-email@example.com","callback_url": "http://x.com/%{token}"}'
```

#### Response

Status: 201

```json
{"id":"6635a744-a7cb-4220-b456-5b24cc061020","email":"some-email@example.com","verification_url":"http://x.com/7c894f9e-3826-4b95-bb75-25a1d2349af0","active":false,"verified":false,"created_at":"2016-07-08T17:33:15Z"}
```

### Verify recipient

#### Request

```bash
# This will be the token applied to the callback_url, visible in the verification_url
export CHALLENGE=7c894f9e-3826-4b95-bb75-25a1d2349af0

curl -XPUT $URL/apps/$APP/recipients/$CHALLENGE/verify \
	-u :$TOKEN
```
#### Response

Status: 204

### List recipients

```bash
curl $URL/apps/$APP/recipients \
	-u :$TOKEN
```

### Activate/deactivate a recipient; and/or refresh the verification URL

- To refresh the verification URL, just pass in the callback_url during PUT requests
- To set the active / inactive flag, set that also.

#### Request

```bash
export ID=6635a744-a7cb-4220-b456-5b24cc061020

curl -XPATCH $URL/apps/$APP/recipients/$ID \
	-u :$TOKEN \
	-d '{"active": false}'

### Refresh callback URL only
curl -XPATCH $URL/apps/$APP/recipients/$ID \
	-u :$TOKEN \
	-H "Content-Type: application/json" \
	-d '{"callback_url": "http://y.com/%{token}"}'

```

#### Response

Status: 200

```json
{"id":"6635a744-a7cb-4220-b456-5b24cc061020","email":"some-email@example.com","verification_url":"http://y.com/67c51bbd-c55d-4d3e-9402-675f59a6242a","active":false,"verified":true,"created_at":"2016-07-08T17:33:15Z"}
```

### Delete a recipient

#### Request

```bash
curl -XDELETE $URL/apps/$APP/recipients/$ID \
	-u :$TOKEN
```

#### Response

Status: 204

## Original Plans left here for posterity

# recipients concrete plans

After looking at the code and weighing in on a good enough design
here's a summary:

## 1. We add a recipients table (most notable is that it should act like a user)

The primary motivation here is to be able to use notifications as it is now with
minimal changes. The only difference is instead of returning a list of users
in the case of `type = Message::EMAIL`, we return a list of recipients for the app.

## 2. Type = app or user stays the same

Nothing needs to change here really.

## 3. Type = dashboard stretch goal

The main idea here is to create notifications, without actually sending emails.
I drafted the line in the notifications mediator around how this might happen.

In terms of flow what happens is:

1. You send a request for `{ target_type: "dashboard", target_id: <app_uuid> }`
   This creates the notifications for users which will be available in `/users/notifications`.
2. You send a request for `{ target_type: "email", target_id: <app_uuid> }`
   Creates notifications for just the active/verified recipients for the given app.

As far as what the metrics-api will execute, it will basically be any of the following
combinations:

```
Dashboard: type=[dashboard]
Dashboard+Email: type=[dashboard, email]
Dashboard+Team: type=[app]
Dashboard+Team+Email: type=[app,email]
```
