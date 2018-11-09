###### Topics

[Requirements](#development-application-requirements) | [Download](#downloading-the-project) | [Install](#install-development-dependancies) | [Startup](#start-local-development) | [Build](#build-for-distribution)

&nbsp;

### Development Application Requirements

The following applications will need to be installed for local development:
- [Git](https://www.google.com/search?q=install%20git&oq=install%20git) 
- [Node](https://nodejs.org/en/)
- [NPM](https://www.npmjs.com/)

### Downloading the Project
Clone the project locally from the Github repository.

### Install Development dependancies
Install Node package dependencies with Node Package Manager.
```
$ npm install
```

### Start local development
Now we can start Node. This will do the following:
- start a localhost server
- automatically compile Coffeescript for the localhost server.
```
$ coffee server.coffee
```

### Build for Distribution
No explicit build process is required. Using the `coffee server.coffee` command above, all Coffeescript is compiled to Javascript which is ready for deployment.