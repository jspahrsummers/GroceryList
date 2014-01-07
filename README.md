# GroceryList [![Build Status](https://travis-ci.org/jspahrsummers/GroceryList.png?branch=master)](https://travis-ci.org/jspahrsummers/GroceryList)

GroceryList is a simple iPhone application built to serve two basic needs:

 1. Creating and managing a grocery list
 1. [Synchronizing](#synchronization) that grocery list between multiple people

The app also serves as an example project for a few different
[frameworks](#frameworks). It is not meant to be feature-complete, polished,
or worth any kind of payment.

If you're only interested in _using_ the app, you can jump straight to [getting
it built](#using-the-app).

![App icon](https://f.cloud.github.com/assets/432536/1798581/b31b7ca6-6b59-11e3-9d6e-42899d81f163.png)

_(Icon created by [@brender](https://github.com/brender).)_

## Synchronization

The app stores and synchronizes its grocery list using [a GitHub
repository](#starting-the-list), since it's easier than writing
a synchronization service, and because Git and the [GitHub
API](http://developer.github.com/) already support atomic changes. This also
means the list is editable from the web, without any need to build a custom
web app.

### List Format

The grocery list repository follows a fairly simple structure. Each grocery
store is represented by a text file of the same name, and those files contain
newline-separated lists of grocery items.

For example, the repository could be comprised of these files:

```
Costco
Safeway
Target
```

Each file will contain items like this:

```
Bread
~Crackers~
Peanut butter
```

Item names with a tilde on either side (`~Crackers~` in the above example) have
been "crossed off" of the list, but not yet deleted.

The same item name may appear in multiple store files. Those separate entries
will be collapsed into one visible item within the app.

## Frameworks

The GroceryList app was built partly as a "real world" demonstration of several
frameworks, including:

 * **[Mantle](https://github.com/MantleFramework/Mantle)**, a lightweight model framework
 * **[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)** (RAC), for functional reactive programming in Cocoa
   * **[ReactiveCocoaLayout](https://github.com/ReactiveCocoa/ReactiveCocoaLayout)**, a RAC library for UI layout
   * **[ReactiveViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel)**, a RAC library for implementing Model-View-ViewModel
 * **[octokit.objc](https://github.com/octokit/octokit.objc)**, a client for the GitHub API (itself built using Mantle and ReactiveCocoa)

Specific libraries aside, the app also serves as a general example of [functional
reactive
programming](http://en.wikipedia.org/wiki/Functional_reactive_programming) (FRP) and
[Model-View-ViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel#model-view-viewmodel)
(MVVM) in Cocoa.

## Using the App

GroceryList is a personal project, not an App Store-quality
download. To actually _use_ it, and share your list with specific people, there
are a few hoops you'll need to jump through first.

Before anything else, make sure to run `script/bootstrap` in your local copy of
the repository. This will automatically clone all submodules used in the
project.

### Starting the List

Since the app is [built on GitHub](#synchronization), it requires a GitHub
repository that all users (you, and anyone you want to share the list with) will
have permission to push to.

First, [create the repository](https://github.com/new). It can be public or
private—just keep in mind the privacy setting when adding grocery items or
stores.

Due to a [known bug](https://github.com/jspahrsummers/GroceryList/issues/10) in
the app, you must have at least one file in the repository before using it. You
can choose to initialize it with a README, or create the file by hand (following
the [list format](#list-format)), just as long as the repository is not empty.

Finally, add anyone with whom you want to share the list as
[collaborators](https://help.github.com/articles/how-do-i-add-a-collaborator) on
the repository.

### Creating an OAuth Application

To be able to log in through the app, it must be configured as a GitHub OAuth
application. Simply [register a new
application](https://github.com/settings/applications/new), making sure to enter
`grocery-list://auth` as the "Authorization callback URL."

After registration, you'll have to add the client ID and secret to the project's
[build settings](#required-build-settings).

### Required Build Settings

Because the author is lazy, the project won't build until (effectively) hardcoded
with certain settings. This is accomplished with a custom Xcode configuration
file that is [specifically ignored](Configuration/.gitignore) by Git.

In your local clone of the repository, inside the `Configuration` folder, create
a file named `UserSettings.xcconfig`. In it, add a line like the following:

```
GCC_PREPROCESSOR_DEFINITIONS=$(inherited) GCY_LIST_REPOSITORY=username/grocery-lists GCY_CLIENT_ID= GCY_CLIENT_SECRET=
```

Replace the value of `GCY_LIST_REPOSITORY` with the actual full name of the
repository containing [the list you created](#starting-the-list). Fill in
`GCY_CLIENT_ID` and `GCY_CLIENT_SECRET` with the details from [the OAuth
application you registered](#creating-an-oauth-application).

After the configuration file has been saved, you should be able to open the
project and build.

### Distribution

The most straightforward way to get up and running with your customized version
of the app is to build it directly to the device of anyone interested in sharing
your grocery list.

However, it may be easier over the long term to use a (totally optional) service
like [HockeyApp](http://hockeyapp.net) or [TestFlight](http://testflightapp.com/) for
distributing builds.

## License

This project is released under the [MIT license](LICENSE.md).
