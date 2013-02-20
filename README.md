# rbenv-binstubs: A Bundler binstubs Plugin for rbenv

This plugin makes [rbenv](http://rbenv.org/) transparently
aware of project-specific binstubs created by [bundler](http://gembundler.com/).

This means you don't have to type `bundle exec ${command}` ever again!

## Installation

To install rbenv-binstubs, clone this repository into your ~/.rbenv/plugins directory. (You'll need a recent version of rbenv that supports plugin bundles.)

    $ mkdir -p ~/.rbenv/plugins
    $ cd ~/.rbenv/plugins
    $ git clone https://github.com/ianheggie/rbenv-binstubs.git 

Then once in each application directory run:

    $ bundle install --binstubs

Bundler will create a bin directory, add in wrappers for each, and remember you want binstubs created each time you run bundle.

## Usage

Simply type the name of the command you want to run! Thats all folks! Eg:

   $ rake --version

This plugin searches from the current directory up towards root for a Gemfile.
If a gemfile is found, and bin/COMMAND is an executable under the same directory, then 
that path is used, otherwise the normal rbenv algorithm applies.

To confirm that the bundler binstub is being used, run the command:

    $ rbenv which COMMAND

To show which gem bundle will use, run the command:

    $ bundle show GEM

You can disable the searching for binstubs by setting the environment variable DISABLE\_BINSTUBS to a non empty string:

    $ DISABLE_BINSTUBS=1 rbenv which command

## License

Copyright (c) 2013 Ian Heggie - Released under the same terms as [rbenv's MIT-License](https://github.com/sstephenson/rbenv#license)

## Known Issues

This plugin only affects those commands that `bundle --binstubs` installs in the `bin` directory

## Similar Projects

[rbenv-bundler](https://github.com/carsomyr/rbenv-bundler) is another rbenv plugin for bundler - it makes shims aware of bundle installation paths. It uses a more involved approach which has performance and other consequences.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit
* Send me a pull request. Bonus points for topic branches.
