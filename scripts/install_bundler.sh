#!/usr/bin/env bash

#
# Installs `bundler` locally in the vendor dir, so that we can use it to `bundle install` on CI
# systems which lacks a full Ruby environment.
#
# Note that any subsequent Ruby scripts ran needs to also have the `$GEM_HOME/bin` path added to
# the `$PATH` before executing.
#

# Set the GEM_HOME so that we can install gems without sudo.
export GEM_HOME="./vendor/gem"
export PATH="$GEM_HOME/bin:$PATH"

hash bundle 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Bundler already installed at \"$(which bundle)\""
else
    echo "No existing Bundler installation found, installing…"
    gem install bundler --no-doc
fi
