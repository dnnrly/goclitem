# Go CLI Template

This is a template for Go CLI tools. Major features are:

1. Setup script
2. Release build action
3. PR validation action
4. Code of Conduct
5. Basic security policy
6. Modules enabled
7. Rudimentary accepance tests

## Setup

1. Create a new repo from this template
2. `$ ./setup.sh`
3. Follow the prompts

## Important `make` targets

* `deps` - downloads all of the deps you need to build, test, and release
* `build` - builds your application
* `test` - runs unit tests
* `acceptance-test` - run the acceptance tests
* `lint` -  run linting
* `update` - update Go dependencies
* `clean` - clean project dependencies
* `clean-deps` - remove all of the build dependencies too
