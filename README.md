# rbenv-binstubs: A Bundler binstubs Plugin for rbenv

This plugin makes [rbenv](http://rbenv.org/) transparently
aware of project-specific binstubs created by [bundler](http://gembundler.com/).

This means you don't have to type `bundle exec ${command}` ever again!

[![Build Status of master](https://api.travis-ci.org/ianheggie/rbenv-binstubs.svg?branch=master)](https://travis-ci.org/ianheggie/rbenv-binstubs)

## Installation

To install rbenv-binstubs, clone this repository into your ~/.rbenv/plugins directory. (You'll need a recent version of rbenv that supports plugin bundles.)

    $ git clone https://github.com/ianheggie/rbenv-binstubs.git "$(rbenv root)/plugins/rbenv-binstubs"

Then for each application directory run the following just once:

    $ bundle install --binstubs .bundle/bin
    $ rbenv rehash

The `.bundle/bin` argument keeps the binstubs separate from the default bin/ since bin/ is now used for application scripts and should be included in your code repository (from rails 4.0.0 onwards). If you wish to mix application scripts and binstubs, then consider [generating only those binstubs you need](https://coderwall.com/p/vhfxia).

I recommend you also install the [gem-rehash](https://github.com/sstephenson/rbenv-gem-rehash) plugin as well so you don't have to remember to use `rbenv rehash` after each `bundle install`. Note gem-rehash only calls rbenv rehash if a new gem executable is installed, so you will need to run `rbenv rehash` for each project directory after installing this plugin or for the specific project if you change the binstub directory.

## Usage

Simply type the name of the command you want to run! Thats all folks! Eg:

    $ rake --version

This plugin searches from the current directory up towards root for a directory containing a Gemfile.
If such a directory is found, then the plugin checks for the desired command under the 'bin' sub-directoy.
If you used bundle --binstubs=some/pib/path then that directory will be checked instead of 'bin'.

To confirm that the bundler binstub is being used, run the command:

    $ rbenv which COMMAND

To show which gem bundle will use, run the command:

    $ bundle show GEM

You can disable the searching for binstubs by setting the environment variable DISABLE\_BINSTUBS to a non empty string:

    $ DISABLE_BINSTUBS=1 rbenv which command

You can list the bundles (project directories) and their associated binstub directories that have been registered since the plugin was installed using the command:
    
    $ rbenv bundles

This will add a comment if bundle is not set to automatically create binstubs, or the binstubs directory is missing, or if a Gemfile no longer exists. If the Gemfile for a bundle is removed, then that bundle will be dropped from the list of bundles to check when `rbenv rehash` is next run.

## License

Copyright (c) 2013 Ian Heggie - Released under the same terms as [rbenv's MIT-License](https://github.com/sstephenson/rbenv#license)

## Links

* [Issues on GitHub](https://github.com/ianheggie/rbenv-binstubs/issues) for Known Issues
* [Wiki](https://github.com/ianheggie/rbenv-binstubs/wiki) for further information
* [Travis-CI](https://travis-ci.org/ianheggie/rbenv-binstubs) for the Continuous integration test results
* [rbenv](https://github.com/sstephenson/rbenv) for rbenv itself
* [plugins on the rbenv wiki](https://github.com/sstephenson/rbenv/wiki/Plugins) includes a list of recomended plugins. I personally use:
  * [ruby-build](https://github.com/sstephenson/ruby-build) - easy install of new ruby versions
  * [rbenv-gem-rehash](https://github.com/sstephenson/rbenv-gem-rehash) - runs rbenv rehash automatically
  * [rbenv-binstubs](https://github.com/ianheggie/rbenv-binstubs) - Of course I use my own plugin!
  * [rbenv-update](https://github.com/rkh/rbenv-update) - update rbenv and plugins with single command
  * [rbenv-env](https://github.com/ianheggie/rbenv-env) - list relevant env variables - I wrote this to better understand what is happening under the hood

## Similar Projects

[rbenv-bundler](https://github.com/carsomyr/rbenv-bundler) is another rbenv plugin for bundler - it makes shims aware of bundle installation paths. It uses a more involved approach which has performance and other consequences.

## Note on Patches/Pull Requests

*Since I no longer using rbenv, I am happy to include pull requests, but I am not actively developing this plugin. If you are interested in taking on this project, either completely or in partnership, please contact me.*

* Fork the project.
* Make your feature addition or bug fix, **with tests**
* Commit
* Send me a pull request. Bonus points for topic branches.

## Contributors

Thanks go to:

* [madumlao](https://github.com/madumlao) - contributed code so this plugin now creates shims for all the executable files in the binstubs directory, thus `bundle --path=vendor/bundle ...` is now handled, as are arbitrary executables in the binstubs directory.
* Various people who have given feedback and suggestions via the [issues list](https://github.com/ianheggie/rbenv-binstubs/issues)

