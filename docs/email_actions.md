# Email actions

Telex supports [Email Actions], a markup added to emails so their clients can provide a better workflow for the reader. You probably saw it before:

![GitHub email actions on Gmail](https://cloud.githubusercontent.com/assets/1144197/4328710/1e480c4c-3f8a-11e4-89df-3735784ca5d5.png)

GitHub added a little markup telling email clients that this message has a "go-to" link, which is rendered that way by Gmail. Email actions can also cover RSVPs, calendar events, reviews and more.


## Support

Telex currently only supports go-to actions, which consist of a link and a label that is rendered to the user. Look at [Minitel](https://github.com/heroku/minitel) for examples on how to use this as a producer.


## Approval with Google

To get Gmail to render these buttons you'll need to request approval by Google.

They will want to know exactly what is going to be emailed out, so start with the email copy, tweak the subject and action label, etc. You can always send yourself an email with action to see how it will look:


```
$ heroku run bin/console -a telex
Running `bin/console` attached to terminal... up, run.6789
> Telex::Emailer.new(email: "pedro@heroku.com", from: "pedro@heroku.com", subject: "Awesome email with an action", body: "yeeah", action: { url: "https://dashboard.heroku.com/foo", label: "Click here!" })
```

After you're happy [follow the steps here](https://developers.google.com/gmail/markup/registering-with-google) to request authorization. Part of the process is to send that email to Google, so you can use the script above to do so too.
