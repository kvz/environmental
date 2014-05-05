Many people think shipping config json files is an upgrade over environment variables. It's not.

Dont't let your app load it's config.

![ruse](https://cloud.githubusercontent.com/assets/26752/2876431/c36febd8-d435-11e3-9159-26436bda3587.png)

..Inject it instead.

Unix environment vars are ideal for configration and I have yet to encounter an application that woudn't be better off with them.

- You can change a value at near-runtime: `DEBUG=*.* node run.js`
- You can inject environment variables into a process belonging to a non-priviliged user: `source envs/production.sh && exec sudo -EHu www-data node run.js`
- You can inherit, inside `staging.sh`, just source `production.sh`, inside `kevin.sh` source `development.sh`
- Your operating system is aware and provides tools for inspection, debugging, optionally passing onto other processes, etc.

And as with any other type of config:

- You can save them into files and keep them out of version control

One downside fo environment variables, is there is little convention and syntactical sugar in the high-level languages. This module attempts to change that.

Environmental Doesn't

 - Break [12-factor](http://12factor.net/)
 - Get in your way

Environmental Does

 - Impose **one way*** of dealing with environment variables
 - Make vars available in nested format inside your app (e.g. `MYAPP_REDIS_HOST`) becomes `config.redis.host`
 - Play well with unix
 - Interpret multiple inherited bash environment files in an isolated environment to capture them, and prepare them for exporting to [Nodejitsu](https://www.nodejitsu.com/documentation/jitsu/env/) or [Heroku](https://devcenter.heroku.com/articles/config-vars).

## Conventions

Environmental tree:

```bash
_default.sh
├── development.sh
│   └── test.sh
└── production.sh
    └── staging.sh.sh
```

On disk:

```bash
envs/
├── _default.sh
├── development.sh
├── production.sh
├── staging.sh
└── test.sh
```

You could make this super-DRY, but I actually recommend using mainly
`development.sh` and `production.sh`, and duplicate keys between them
so you can easily compare side by side.
Then just use _default.sh, test.sh, staging.sh for tweaks, to keep things
clear.

These variables are mandatory and have special meaning

  - NODE_APP_PREFIX="MYAPP" # filter and nest vars starting with MYAPP right into your app
  - NODE_ENV="production"   # the environment your program thinks it's running
  - DEPLOY_ENV="staging"    # the machine you are actually running on
  - DEBUG=*.*               # Used to control debug levels per module

After getting that out of the way, feel free to start hacking on, prefixing all
vars with MYAPP a.k.a an actuall short abbreviation of your app name.

export NODE_APP_PREFIX="TLS"

## Getting started

In a new project, type

```bash
$ npm install --save environmental
```

This will install the node module. Next you'll want to set up an example environment using these templates:

```bash
cp -Ra node_modules/environmental/envs ./envs
```

You'll want to add `envs/*.sh` to your project's `.gitignore` file so they are not accidentally committed into your repository. Having env files in Git can be convenient for protoyping, but once you go live you'll want to change all credentails and sync your env files separate from your code.

## Usage inside app

You can also use it inside an app:

```bash
source envs/development.sh && node myapp.js
```

```javascript
var Environmental = require ('environmental');
var environmental = new Environmental();
var config        = environmental.nested(process.env, process.env.NODE_APP_PREFIX);

console.log(config);

// Will return
//
//   { redis: { host: '127.0.0.1' } }
```

As you see, any underscore `_` in env var names signifies a new nesting level of configuration, and all keys are lowercased.

## Exporting to Nodejitsu

```bash
$ ./bin/environmental envs/production.sh
{"MYAPP_REDIS_PORT":"6379","NODE_APP_PREFIX":"MYAPP","MYAPP_REDIS_PASS":"","DEPLOY_ENV":"production","SUBDOMAIN":"mycompany-myapp","NODE_ENV":"production","MYAPP_REDIS_HOST":"127.0.0.1","DEBUG":""}
$ ./bin/environmental envs/production.sh > /tmp/jitsu-env.json
$ jitsu --confirm env load /tmp/jitsu-env.json
$ jitsu --confirm deploy
```

## Exporting to Heroku
