# Invites are joined by code only in v1

A person joins a Household by typing its Invite code. v1 has no invite links.

A link that opens the app has to be either a custom scheme (`homeapp://join/K7M2Q9`) or an `https://` link. WhatsApp, the main way Invites are shared, does not make custom-scheme links clickable. An `https://` link needs a domain we own, hosting for the Android App Links (`assetlinks.json`) and iOS Universal Links (`apple-app-site-association`) verification files, and a fallback web page for people without the app. That is setup with no real payoff before launch, while a short code pasted from WhatsApp works today.

## Considered Options

- **`https://` link on our own domain**: the right long-term answer. To add it later: buy a domain, host the two verification files and a small join page (GitHub Pages is enough), add a go_router route for `/join/<code>`, and configure App Links and Universal Links. The code stays as the way in when a link fails.
- **Custom-scheme link**: rejected because it is not clickable in WhatsApp.
