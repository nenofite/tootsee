[\@tootsee\@botsin.space](https://botsin.space/@tootsee)
========================================================

Let’s make a Mastodon bot! We’ll name them Tootsee. Here’s the idea:

1.  You toot at the bot.

2.  The bot grabs the first image off DuckDuckGo that matches your toot.

3.  The bot uses Microsoft’s machine vision API to caption that image.

4.  The bot replies to your toot with Microsoft’s caption.

It’s like a game of telephone but with neural nets.

## Setting Up For Development
### Prereqs
You will need the following before setting up the project locally on your computer.

* Mastodon account Access Token (Can be found in your desired Mastodon instance's Settings > Development > New Application)
  * Enable read, write, and push permissions.

* One of the two keys from your Microsoft Azure Computer Vision resource (Free plan available)

* The URL to call the Microsoft Azure Computer Vision resource
  * Usually in the format of `https://some_geographic_location.api.cognitive.microsoft.com/vision/v1.0`

### Setup
1. To set up the project, you will need to install Crystal, the programming language used in this project. [You can follow the instructions found here to install it on your system](https://crystal-lang.org/docs/installation/).

2. Once that is installed, set up the project and set up the dependencies by running `shards install`.

3. Next you will need to set up environmental variables.
```bash
export AZURE_KEY="[REPLACE WITH YOUR AZURE KEY HERE]"
export AZURE_URL="[REPLACE WITH YOUR AZURE COMPUTER VISION SERVER URL]/analyze"
export PORT=[PICK YOUR FAVORITE PORT]
export ACCESS_TOKEN="[REPLACE WITH YOUR MASTODON ACCESS TOKEN]"
export MASTO_URL="[REPlACE WITH YOUR MASTODON INSTANCE URL WITHOUT PROTOCOL]"
```

as an example it might look something like this:
```bash
export AZURE_KEY="ab3813dae9b8fe09fa09b3e70fb3bfae70fb3e70fb3bf78"
export AZURE_URL="https://eastus.api.cognitive.microsoft.com/vision/v1.0/analyze"
export PORT=7007
export ACCESS_TOKEN="8febab38ba0704fa070fb370f9f013dae9bf09f8"
export MASTO_URL="botsin.space"
```

4. Next, start the webserver with `crystal run app.cr` and tootsee away~

## Technical Implementation

### Retrieving Mentions from Mastodon

Tootsee subscribes to push notifications. This way, Mastodon will call our
webhook whenever a user toots at tootsee.

To subscribe, we post once to `/api/v1/push/subscription`. We specify the
following form data:

-   `subscription[endpoint]` is the URL for the webhook to post to. We’ll use
    `/push` on our Heroku server.

-   `subscription[keys][p256dh]` is our public key. We’ll decrypt the webhooks
    sent to us with this key. That way, we verify that they were sent by
    Mastodon and not some third party.

-   `subscription[keys][auth]` is a throw-away random value. Not sure why we
    need this \\o/

-   `data[alerts][mention]` is true. This tells Mastodon that we only care about
    mentions.

Then we listen for posts to our `/push` endpoint. These requests will contain
the triggering notification. In our case, it’s always a “mention” notification.
We care about these fields:

-   `type` should always be `mention`. If not, we’ll ignore the notification.

-   `account[acct]` is the handle of the user who mentioned tootsee.

-   `status[id]` is the ID of the toot. We’ll need it to reply to the toot.

-   `status[content]` is the HTML content of the toot. We’ll strip the HTML
    before using it.

### Getting Images

Todo

### Captioning Images

Todo

### Replying to Mentions

To send a reply toot, we post to `/api/v1/statuses` and specify:

-   `status` is the text of our toot.

-   `in_reply_to_id` is the ID of the toot we’re replying to.

### References

-   [Mastodon
    API](https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md)

-    
