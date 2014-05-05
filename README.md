Many people think shipping config json files is an upgrade over environment variables. It's not.

Don't let your app load its config.

![687474703a2f2f6769666174726f6e2e636f6d2f77702d636f6e74656e742f75706c6f6164732f323031332f30322f6974735f615f747261702e676966](https://cloud.githubusercontent.com/assets/26752/2877380/764960a4-d44a-11e3-8ac4-afd5f1678bb2.gif)

... inject it instead.

Unix environment vars are ideal for configuration and I have yet to encounter an application that woudn't be better off with them.

- You can change a value at near-runtime: `DEBUG=*.* node run.js`
- You can inject environment variables into a process belonging to a non-privileged user: `source envs/production.sh && sudo -EHu www-data node run.js`
- You can inherit, inside `staging.sh`, just source `production.sh`, inside `kevin.sh` source `development.sh`
- Your operating system is aware and provides tools for inspection, debugging, optionally passing onto other processes, etc.

And as with any other type of config:

- You can save them into files and keep them out of version control

One downside of environment variables is that there is little convention and syntactic sugar in the high-level languages. This module attempts to change that.

Environmental Doesn't

 - Break [12-factor](http://12factor.net/)
 - Get in your way

Environmental Does

 - Impose **one way** of dealing with environment variables
 - Make vars available in nested format inside your app (e.g. `MYAPP_REDIS_HOST`) becomes `config.redis.host`
 - Play well with unix
 - Interpret multiple inherited bash environment files in an isolated environment to capture them, and prepare them for exporting to [Nodejitsu](https://www.nodejitsu.com/documentation/jitsu/env/) or [Heroku](https://devcenter.heroku.com/articles/config-vars).

## Conventions

### Layout

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

You could make this super-[DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself), but I actually recommend using mainly
`development.sh` and `production.sh`, and duplicate keys between them
so you can easily compare side by side.
Then just use `_default.sh`, `test.sh`, `staging.sh` for tweaks, to keep things
clear.

### Inheritance can be a bitch

One common pitfall is re-use of variables:

```bash
export MYSQL_HOST="127.0.0.1"
export MYSQL_URL="mysql://user:pass@${MYSQL_HOST}/dbname"
```

Then when you extend this and only override `MYSQL_HOST`, obviously the `MYSQL_URL` will remain unaware of your host change. Ergo: duplication of vars might be the lesser evil than going out of your way to DRY things up.

### Mandatory and unprefixed variables

These variables are mandatory and have special meaning:

```bash
export NODE_APP_PREFIX="MYAPP" # filter and nest vars starting with MYAPP right into your app
export NODE_ENV="production"   # the environment your program thinks it's running
export DEPLOY_ENV="staging"    # the machine you are actually running on
export DEBUG=*.*               # used to control debug levels per module
```

After getting that out of the way, feel free to start hacking, prefixing all
other vars with `MYAPP` - or the actual short abbreviation of your app name. Don't use an underscore `_` in this name.

In this example, `TLS` is our app name:

```bash
export NODE_APP_PREFIX="TLS"
export TLS_REDIS_HOST="127.0.0.1"
export TLS_REDIS_USER="jane"
```

## Getting started

In a new project, type

```bash
$ npm install --save environmental
```

This will install the node module. Next you'll want to set up an example environment as shown in layout, using these templates:

```bash
cp -Ra node_modules/environmental/envs ./envs
```

Add `envs/*.sh` to your project's `.gitignore` file so they are not accidentally committed into your repository.  
Having env files in Git can be convenient as you're still protoyping, but once you go live you'll want to change all credentails and sync your env files separate from your code.

## Accessing config inside your app

Start your app in any of these ways:

```bash
source envs/development.sh && node myapp.js
```

Inside your source you can obviously just access `process.env.MYAPP_REDIS_HOST`, but **Environmental** also provides some syntactic sugar so you could type `config.redis.host` instead. Here's how:

```javascript
var Environmental = require ('environmental');
var environmental = new Environmental();
var config        = environmental.nested(process.env, process.env.NODE_APP_PREFIX);

console.log(config);

// This will return
//
//   { redis: { host: '127.0.0.1' } }
```

As you see

 - any underscore `_` in env var names signifies a new nesting level of configuration
 - all remaining keys are lowercased

## Exporting to Nodejitsu

Nodejitsu als works with environment variables. But since they are hard to ship, they want you to bundle them in a json file.

Environmental can create such a temporary json file for you. In this example it figures out all vars from `envs/production.sh` (even if it inherits from other files):

```bash
$ ./node_modules/.bin/environmental envs/production.sh
{"MYAPP_REDIS_PORT":"6379","NODE_APP_PREFIX":"MYAPP","MYAPP_REDIS_PASS":"","DEPLOY_ENV":"production","SUBDOMAIN":"mycompany-myapp","NODE_ENV":"production","MYAPP_REDIS_HOST":"127.0.0.1","DEBUG":""}
$ ./node_modules/.bin/environmental envs/production.sh > /tmp/jitsu-env.json
$ jitsu --confirm env load /tmp/jitsu-env.json
$ jitsu --confirm deploy
$ rm /tmp/jitsu-env.json
```

## Exporting to Heroku

@TODO

## Exporting to your own server

You could use rsync for this. For instance, here we use a `Makefile` to sync config to the staging machines:

```bash

config-pull:
    @echo "--> If you haven't already, please make a envs/staging.sh and with MYAPP_SSH_* vars for staging"
    @source envs/staging.sh; \
      for sshHost in `echo $${MYAPP_SSH_HOSTS}`; do \
        rsync \
         --recursive \
         --links \
         --perms \
         --times \
         --devices \
         --specials \
         --progress \
         --rsh="$${MYAPP_SSH_OPT}" $${sshHost}:$${MYAPP_DIR}/envs/ ./envs; \
        break; \
      done

config-push:
    @source envs/staging.sh; \
      for sshHost in `echo $${MYAPP_SSH_HOSTS}`; do \
        rsync \
         --recursive \
         --links \
         --perms \
         --times \
         --devices \
         --specials \
         --progress \
         --rsh="$${MYAPP_SSH_OPT}" ./envs/ $${sshHost}:$${MYAPP_DIR}/envs; \
      done
```

## Injecting into a non-privileged user process

When you deploy your app into production and you run the servers yourself, you might want to use upstart to respawn your process after crashes.

Here's how an upstart file (`/etc/init/myapp`) could look like, where the root user injects the environment keys into process memory of an unpriviliged user.

This has the big security advantage that you own program cannot even read its credentials from disk.

```bash
stop on runlevel [016]
start on (started networking)

# The respawn limits function as follows: If the process is respawned
# more than count times within an interval of timeout seconds,
# the process will be stopped automatically, and not restarted.
# Unless set explicitly, the limit defaults to 10 times within 5 seconds.
# http://upstart.ubuntu.com/wiki/Stanzas#respawn_limit
respawn
respawn limit 10 5

limit nofile 32768 32768

pre-stop exec status ${MYAPP_UNIXNAME} | grep -q "stop/waiting" && initctl emit --no-wait stopped JOB=${MYAPP_UNIXNAME} || true

script
  set -e
  set -x
  mkfifo /tmp/${MYAPP_UNIXNAME}-log-fifo
  ( logger -t ${MYAPP_UNIXNAME} </tmp/${MYAPP_UNIXNAME}-log-fifo & )
  exec >/tmp/${MYAPP_UNIXNAME}-log-fifo
  rm /tmp/${MYAPP_UNIXNAME}-log-fifo
  exec bash -c "cd ${MYAPP_DIR} \
    && chown root.root envs/*.sh \
    && chmod 600 envs/*.sh \
    && source envs/${MYAPP_DEPLOY_ENV}.sh \
    && exec sudo -EHu ${MYAPP_SERVICE_USER} make start 2>&1"
end script
```

## Todo

 - Better (more compact, more consise) API language
 - Offer better ideas / docs for syncing config without Git
 - More tests
 - Integrate with Heroku as an export target
