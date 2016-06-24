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
