# LocomotiveCMS::Wagon

[![Gem Version](https://badge.fury.io/rb/locomotivecms_wagon.svg)](http://badge.fury.io/rb/locomotivecms_wagon) [![Code Climate](https://codeclimate.com/github/locomotivecms/wagon/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/wagon) [![Dependency Status](https://gemnasium.com/locomotivecms/wagon.png)](https://gemnasium.com/locomotivecms/wagon) [![Build Status](https://travis-ci.org/locomotivecms/wagon.svg?branch=master)](https://travis-ci.org/locomotivecms/wagon) [![Coverage Status](https://coveralls.io/repos/locomotivecms/wagon/badge.svg?branch=master)](https://coveralls.io/r/locomotivecms/wagon?branch=master)

Wagon is the official site generator for the LocomotiveCMS engine powered by all the efficient and modern HTML development tools (Haml, SASS, Compass, Less).

## Documentation

Please, visit the documentation website of LocomotiveCMS.

  [http://doc.locomotivecms.com](http://doc.locomotivecms.com)

## Developers / Contributors

### Get the development of the mounter

    $ git clone git://github.com/locomotivecms/mounter.git

  Note: If you want to contribute, you may consider to fork it instead

### Get the source of the wagon

    $ git clone git://github.com/locomotivecms/wagon.git
    $ cd wagon

  Note: Again, if you want to contribute, you may consider to fork it instead

  Modify the Gemfile to change the link to the *mounter* gem which should point to your local installation of the mounter.

    $ bundle install

### Test it

#### Run the server with a default site

    $ bundle exec bin/wagon serve spec/fixtures/default

#### Push a site

    $ bundle exec bin/wagon push <path to your LocomotiveCMS local site> <url of your remote LocomotiveCMS site> <email of your admin account> <password>

#### Pull a site

    $ bundle exec bin/wagon pull <url of your remote LocomotiveCMS site> <email of your admin account> <password>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contact

Feel free to contact me (did at locomotivecms dot com).

Copyright (c) 2013 NoCoffee, released under the MIT license
