###### Topics

[Development Stack](#development-stack) | [Key Libraries](#key-libraries) | [Integrations](#integrations)

&nbsp;

# Development Stack

&nbsp;

## Middleman

We use a Ruby powered static site generator to compile meta languages and render templates into the final build files.

Middleman has a unique and powerful development cycle that allows developers to rapidly code and compile on the fly while observing changes locally. [Middleman Development Cycle](https://middlemanapp.com/basics/development_cycle/)

To get started with Middleman you'll need Ruby and Xcode Command Line Tools. [Middleman Installation Instructions](https://middlemanapp.com/basics/install/)

Our primary use of Middleman includes the following:
* Compile Meta Languages
  * Haml to HTML
  * SASS to CSS
  * Coffeescript to Javascript
  * SASS [Compass](http://compass-style.org/) utility
* Render pages using [Layouts](https://middlemanapp.com/basics/layouts/)
* Render HTML fragments using [Partials](https://middlemanapp.com/basics/partials/)
* [Helper Methods](https://middlemanapp.com/basics/helper_methods/) to render markup, variables, and placeholder content.

**HTML vs Haml**
One caveat of using the Haml meta language is that the Middleman documentation examples are in HTML. This reduces the clarity between our New Framework source code and the Middleman documentation examples. There are 3rd party websites that can help translate the HTML examples into the Haml equivalent, such as [html2haml](https://html2haml.herokuapp.com/).

###### Website: [middlemanapp.com](https://middlemanapp.com)

&nbsp;

## Bower

Bower is a Javascript package manager. We use a Ruby Gem integration `gem 'middleman-bower'` that hooks Bower into Middleman's asset pipeline.

The Frameworks uses Bower to include the Javascript dependencies via application.js.

###### Website: [bower.io](https://bower.io/)

&nbsp;

## Haml

Haml is a HTML meta language. It provides an efficient syntax that compiles to regular HTML.

All Framework HTML files are built using the Haml syntax. Haml is automatically compiled by [Middleman](https://github.com/Peopledesign/interface-new-framework/wiki/Development-Stack/#middleman).

###### Website: [haml.info](http://haml.info/)

&nbsp;

## SASS

SASS is a CSS meta language. It provides variables, functions, advanced calculations, and a minimal syntax and compiles to regular CSS. We use the SASS [indented syntax](http://sass-lang.com/documentation/file.INDENTED_SYNTAX.html) for all SASS files in the project.

All Framework CSS files are built using the SASS syntax. SASS is automatically compiled by [Middleman](https://github.com/Peopledesign/interface-new-framework/wiki/Development-Stack/#middleman).

###### Website: [sass-lang.com](http://sass-lang.com/)

&nbsp;

## Coffeescript

Coffeescript is a Javascript meta language. It provides a minimal and efficient syntax and compiles to regular Javascript.

All Framework Javascript files are built using the Coffeescript syntax. Coffeescript is automatically compiled by [Middleman](https://github.com/Peopledesign/interface-new-framework/wiki/Development-Stack/#middleman).

###### Website: [coffeescript.org](http://coffeescript.org/)

&nbsp;

# Key Libraries
These libraries form the majority of the front end framework.

## Foundation
The front end visual framework:
- Version 5.5.3
- Full Documentation on [foundation.zurb.com](https://foundation.zurb.com/sites/docs/v/5.5.3/)

## Backbone.js 
The javascript model / view library:
- Version 1.1.0
- Full Documentation on [backbonejs.org](http://backbonejs.org/)


&nbsp;

# Integrations
This project relies on a few 3rd party integrations to power the front end abilities.

## Eloqua
The Eloqua `data lookup` API feature is used in the javascript to pull in customer data. This data is used to autocomplete the order form in the product detail modal. The data lookup requires a customer GUID cookie. If none is found, the form fields are not auto filled.

We also use an Eloqua form on the homepage banner to sign up users to the specials Eloqua campaign.

Unfortunately, Eloqua does not officially document the javascript data lookup API. Our implementation of this feature relied on piecing together Eloqua community blog posts.

## Firebase
This project uses Firebase's database feature to store the Specials product data. Key javascript libraries for interfacing with Firebase on the front end:
- [Firebase](https://github.com/firebase/firebase-bower) v2.0.6
- [BackboneFire](https://github.com/firebase/backbonefire) 0.5.1

Together, these libraries provide read / write capability to the front end javascript.

Firebase originally was just a cloud database service. Since this project's creation, Firebase has expanded its services into hosting and and storage as well. 

## Adobe Scene7
Specials relies on Interface's Adobe Scene7 account to generate all product images.

&nbsp;