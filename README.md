# Crackin

Simple, generalized way to handle gem releases.

Much of this code has been developing over time 
in a bunch of my projects. I decided to pull it 
all together into one place.

## Philosophy

* Use semantic versioning, as much as possible. http://semver.org
  * doesn't currently support build numbers or architectures.
* Support MAJOR _1_.0.0 releases
* Support MINOR 0._1_.0 releases
* Support TINY 0.0._1_ releases
* Support TAG (pre) releases
  * release candidate: 0.1.0._rc1_
  * beta: 0.1.0._beta1_
  * alpha: 0.1.0._alpha1_
* Manage the release process similar to git flow.

## Installation

Add this line to your application's Gemfile:

    gem 'crackin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crackin

## Usage

Once `Crackin` has been added to your bundle or installed, you can do the following:

`crackin init`

This will create a `.crackin.yml` file and a `CHANGELOG.md` file (if it doesn't already exist).
The command's output will prompt with you further inforamtion.

## Status

Use the `crackin status` command to get more information. The general idea is:

1. work on code in your development branch (default: 'develop')
   or work on code in feature branches and merge to development branch
2. once everything is merged to development and pushed, you can start a release.

3. `crackin release <type>`
   * create a temporary release branch from master
   * merge from develop
   * update version file
   * update changelog file
   * allow you to make any final updates (this is normally for customizing the changelog)
4. Once you're finished with changes (you don't need to commit them).
5. `crackin release finish`
   * add and commit changes to release branch
   * merge release branch to master
   * create a tag
   * run a gem build (currently uses bundler gem task)
   * push master
   * push tags
   * push gem
   * merge master to develop
   * delete release branch (this should be configurable)
   * push develop

## Files

### Configuration file

An example of the configuration file. _Subject to change_

```
---
crackin:
  name: crackin
  debug: false
  version: lib/crackin/version.rb
  scm: git
  changelog: CHANGELOG.md
  branch:
    production: master
    development: develop
  status:
    verbose: true
  build:
    command: rake build
    after: []
```

Pay special attention to `name` and `version`, these values must be set after initialization.

### Version file

The format that `Crackin` expects for the version.rb file of your gem.

```
module Crackin
  module Version
    MAJOR = 0
    MINOR = 1
    TINY = 0
    TAG = nil
    LIST = [MAJOR, MINOR, TINY, TAG]
    STRING = LIST.compact.join(".")
  end
end
```

It uses this format to manipulate the values during releases.

### Changelog file

The format of the changelog file.

```
### Changelog

##### v0.1.0:
* add 'add' method to scm api
* add some more inforation to initialization. fix bug with name of method in scm: git. make sure *all* files are added before commit during a crackin release finish.

##### v0.0.1.rc0:
* initial
```

Currently, `Crackin` just includes all commit *subjects* for each tag. It does this by walking the tags
and getting the commits between them.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
