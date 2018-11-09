###### Topics

[Requirements](#development-application-requirements) | [Download](#downloading-the-project) | [Install](#install-development-dependancies) | [Startup](#start-local-development) | [Build](#build-for-distribution)


&nbsp;

### Development Application Requirements

The following applications will need to be installed for local development:
- [Ruby](https://www.ruby-lang.org/en/) & [RubyGems](https://rubygems.org)
- [Git](https://www.google.com/search?q=install%20git&oq=install%20git) 
- [Node](https://nodejs.org/en/)
- [NPM](https://www.npmjs.com/)
- [Bower](https://bower.io/)

### Downloading the Project
Clone the project locally from the Github repository.

### Install Development dependancies
Install the Middleman Ruby Gem dependencies. 
```
$ bundle install
```

Install Bower package dependencies. 
```
$ bower install
```

### Start local development
Now we can start Middleman. This will do the following:
- start a localhost server
- automatically compile any Coffeescript or SASS for the localhost server.
```
$ bundle exec middleman
```

### Build for Distribution
Middleman will compile and build all source files into the `build` directory when we run the following:
```
$ bundle exec middleman build
```
