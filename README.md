# LocomotiveCMS::Wagon

The LocomotiveCMS wagon is a site generator for the LocomotiveCMS engine powered by all the efficient and modern HTML development tools (Haml, SASS, Compass, Less).

(TO BE COMPLETED)

## Developers / Alpha users / Contributors

The push/pull functionalities require to have the edge version of the engine (master branch).
Also, please, keep in mind, that is nearly an alpha version so it is not stable enough to be used in production.

### Get the development of the mounter

    $ git clone git://github.com/locomotivecms/mounter.git

  Note: If you want to contribute, you may consider to fork it instead

### Get the source of the wagon

    $ git clone git://github.com/locomotivecms/wagon.git
    $ cd wagon
    $ git checkout wip

  Note: Again, if you want to contribute, you may consider to fork it instead

  Modify the Gemfile to change the link to the *mounter* gem which should point to your local installation of the mounter.

    $ bundle install

### Test it

#### Run the server with a default site

    $ bundle exec bin/wagon server <path to the mounter gem>/spec/fixtures/default

#### Push a site (WIP)

    $ bundle exec bin/wagon push <path to your LocomotiveCMS local site> <url of your remote LocomotiveCMS site> <email of your admin account> <password>

#### Pull a site (Not tested yet)

    $ bundle exec bin/wagon pull <url of your remote LocomotiveCMS site> <email of your admin account> <password>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Installation (TODO)

Add this line to your application's Gemfile:

    gem 'locomotive_wagon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install locomotive_wagon

## Usage

TODO: Write usage instructions here
