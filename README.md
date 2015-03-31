# LimesurveyRails
[![Build Status](https://travis-ci.org/masciugo/limesurvey_rails.svg?branch=master)](https://travis-ci.org/masciugo/limesurvey_rails)

A limesurvey plugin for Rails to make an ActiveRecord model able to participate to Limesurvey surveys

## Premise

This is a very very poor readme. I use this gem in my projects but I can't describe it better because I'm busy. But if anyone is interested just contact me 

## Installation

Add this line to your application's Gemfile:

    gem 'limesurvey_rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install limesurvey_rails

## Usage

In your participant model simply execute from your model class

    is_a_limesurvey_participant

but there are many options ..

## Test

Because of [this](http://stackoverflow.com/questions/22667421/test-rails-model-with-several-initializations-with-rspec) it's better run test separately (in a real scenario the *participant model* is expected to be initialized only once):

    rake spec[main] && rake spec[survey] && rake spec[participant] && rake spec[participation]

Reminder for further bug investigation:

    rake spec[,25280] #failing test
    rake spec[survey,25280] #passing test

## Contributing

1. Fork it ( https://github.com/[my-github-username]/limesurvey_rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
