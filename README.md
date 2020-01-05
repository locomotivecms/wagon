# Wagon

[![Gem Version](https://badge.fury.io/rb/locomotivecms_wagon.svg)](http://badge.fury.io/rb/locomotivecms_wagon) [![Code Climate](https://codeclimate.com/github/locomotivecms/wagon/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/wagon) [![Build Status](https://travis-ci.com/locomotivecms/wagon.svg?branch=master)](https://travis-ci.com/locomotivecms/wagon) [![Coverage Status](https://coveralls.io/repos/locomotivecms/wagon/badge.svg?branch=master)](https://coveralls.io/r/locomotivecms/wagon?branch=master) [![Join the chat at https://gitter.im/locomotivecms/wagon](https://badges.gitter.im/locomotivecms/wagon.svg)](https://gitter.im/locomotivecms/wagon?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Wagon is a command line tool that let's you develop for Locomotive right on your local machine.

With Wagon, you can generate the scaffolding for a new Locomotive site and start adding the content types and templates you need using any text editor. And thanks to Wagon's built-in web server, you can preview the site with your computer's web browser.

Wagon can also deploy sites to any Locomotive Engine using the wagon deploy command. Your changes will immediately be reflected on that site without restarting or making any changes to the Engine server app.

To help you work faster, Wagon comes with support for tools like SASS, LESS, HAML, and CoffeeScript. It also works well with source version control systems like git and svn.

**Note:** The previous version of Wagon (v1.5.8) is available in the *[v1.5.x](https://github.com/locomotivecms/wagon/tree/v1.5.x)* branch

## Documentation

Please, visit the documentation website of Locomotive.

  [https://doc.locomotivecms.com](https://doc.locomotivecms.com)

**Note:** The documentation for the previous version (v1.5.x) is available [here](http://doc-v2.locomotivecms.com/).

## Developers / Contributors

### Get the development version of the Steam gem

    $ git clone git://github.com/locomotivecms/steam.git

  Note: If you want to contribute, you may consider to fork it instead

### Get the source of Wagon

    $ git clone git://github.com/locomotivecms/wagon.git
    $ cd wagon

  Note: Again, if you want to contribute, you may consider to fork it instead

  Modify the Gemfile to change the link to the *steam* gem which should point to your local installation of Steam.

    $ bundle install

### Test it

#### Run the spec tests

    $ bundle exec rake spec

#### Run the server with a default site

    $ bundle exec bin/wagon serve spec/fixtures/default

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contact

Feel free to contact me (didier at nocoffee dot fr).

Copyright (c) 2020 NoCoffee, released under the MIT license
