# Basilisk
A Viral Loop for Programmers

## What is Basilisk?

**Basilisk** is a viral loop for programmers.  We host our source code on [GitHub](https://github.com/brainix/basilisk), continuously deploy with [Travis CI](https://travis-ci.org/brainix/basilisk), and host our website on [Heroku](http://basilisk.us/).  We then use our website to invite our friends to collaborate on Basilisk on GitHub.

Since we deploy continuously, if you push changes to our code on GitHub, you&rsquo;ll see your changes on our live website on Heroku in minutes.

[![Build Status](https://travis-ci.org/brainix/basilisk.svg?branch=master)](https://travis-ci.org/brainix/basilisk)

## How can I help?

1. [Request an invitation](mailto:basilisk@74inc.com?subject=Invite Me!) to collaborate.
2. Vandalize our site.
3. Invite your friends to collaborate.
4. Post about Basilisk anywhere you want.

## Why the name &ldquo;Basilisk&rdquo;?

I named this project after Roko&rsquo;s Basilisk.  &ldquo;**Warning**: Reading [this article](http://www.slate.com/articles/technology/bitwise/2014/07/roko_s_basilisk_the_most_terrifying_thought_experiment_of_all_time.html) [about Roko&rsquo;s Basilisk] may commit you to an eternity of suffering and torment.&rdquo;

## Hacking

Complete the following steps in the same Terminal session to avoid unnecessary complexity.

1. Install [Xcode](https://developer.apple.com/xcode/downloads/).
2. Install the Xcode command line tools:
  1. In Terminal, issue the command: `$ gcc`
  2. If the command line tools aren&rsquo;t installed, OS X will prompt you to install them.
3. Install [Homebrew](http://brew.sh); in Terminal, issue the command: `$ ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"`
4. Install [RVM](https://rvm.io) and Ruby 2.1.5; in Terminal, issue the commands:
  1. `$ \curl -sSL https://get.rvm.io | bash -s stable`
  2. `source $HOME/.rvm/scripts/rvm`
  3. `$ rvm install 2.1.5`
5. Ensure that you&rsquo;re using Ruby 2.1.5; in Terminal, issue the command: `$ rvm use 2.1.5`
6. Install [Redis](http://redis.io); in Terminal, issue the command: `$ brew install redis`
7. Install the [Heroku Toolbelt](https://toolbelt.heroku.com).
8. Clone this git repo; in Terminal, issue the commands:
  1. `$ git clone https://github.com/brainix/basilisk.git`
  2. `$ cd basilisk/`
9. Install Basilisk&rsquo;s Ruby gem dependencies; in Terminal, issue the command: `$ bundle install`
10. Configure your development environment variables; in Terminal, issue the command: `$ cp .env.example .env`, then edit your `.env` file and fill in the appropriate values.

At this point, in Terminal, you should be able to issue the command `$ foreman start` to launch Redis and Basilisk.  Point your web browser to [http://localhost:5100/](http://localhost:5100/) and rejoice!
