# rbenv-binstubs: A Bundler binstubs Plugin for rbenv

This plugin makes [rbenv](http://rbenv.org/) transparently
aware of project-specific binstubs created by [bundler](http://gembundler.com/).

It saves you from the hassle of having to type `bundle exec ${command}`.

## Installation

To install rbenv-binstubs, clone this repository into your ~/.rbenv/plugins directory. (You'll need a recent version of rbenv that supports plugin bundles.)

    $ mkdir -p ~/.rbenv/plugins
    $ cd ~/.rbenv/plugins
    $ git clone https://github.com/ianheggie/rbenv-binstubs.git 

Then generate bundle binstubs as per [Understanding binstubs](https://github.com/sstephenson/rbenv/wiki/Understanding-binstubs)

    $ bundle --binstubs

## Usage

Chdir to the directory your Gemfile exists in, and then run commands as normal (without prefixing with `bundle exec ` or `bin/`).

Run the command

    $ rbenv which COMMAND

To confirm that bin/COMMAND is being used.

## License

Copyright (c) 2013 Ian Heggie - Released under the same terms as [rbenv's MIT-License](https://github.com/sstephenson/rbenv#license)

## Known Issues

This plugin only affects those commands that `bundle --binstubs` installs in the
`bin` directory, and only if the current working directory contains a `Gemfile` file.

Pull requests with bug fixes / enhancements are welcome, especially to make it work without having to cd to the project root, or to add travis-ci tests.

## Similar Projects

[rbenv-bundler](https://github.com/carsomyr/rbenv-bundler) is another rbenv plugin for bundler - it makes shims aware of bundle installation paths. It uses a more involved approach which has performance and other consequences.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit
* Send me a pull request. Bonus points for topic branches.
