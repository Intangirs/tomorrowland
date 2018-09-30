Tomorrowland
===================

Next Generation Mastodon Client for iOS

Onboarding
===================

You need to set up build environment first.
I ignore credential information from git, so I will pass that info to you when you join our development team!

We have two files that manage secret keys.

- .env.default
- TomorrowLand/Mastodon/Keys.swift

First one is used by `fastlane`, on top of `dotenv`.
Secondone has mastodon API client ID and client secret, redirect uri, scope.

* For .env.default, **you just copy and paste information there.**
* for keys.swift, **you create duplicate file of Keys.sample.swift, and modify content.**
