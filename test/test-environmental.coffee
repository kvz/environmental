should        = require("chai").should()
expect        = require("chai").expect
Environmental = require "../src/environmental"

describe "Environmental", ->

  describe "config", ->
    it "should be config and lowercases", (done) ->
      config = Environmental.config
        MYAPP_REDIS_HOST: "127.0.0.1"
      , "MYAPP"

      expect(config).to.deep.equal
        redis:
          host: "127.0.0.1"
      done()

    it "should default to process.env and be able to find the HOME env var", (done) ->
      console.log
        processEnv: process.env
      config = Environmental.config()
      expect(config).to.have.ownProperty('home');
      done()

    it "should allow to disable filtering via false", (done) ->
      config = Environmental.config
        parent:
          child: "1"
      , false
      expect(config).to.have.ownProperty('parent');
      done()

    it "should support the convenience shortcut", (done) ->
      config = (require "../src/environmental").config
        "PARENT_CHILD": "1"
      expect(config).to.deep.equal
        parent:
          child: "1",
      done()

  describe "capture", ->
    it "should be able to capture production.sh and ignore MYAPP_REDIS_PORT", (done) ->
      env = new Environmental
        ignore: [
          "MYAPP_REDIS_PORT"
          "PWD"
          "SHLVL"
          "_"
        ]
      capture = env.capture "#{__dirname}/../envs/production.sh", (err, flat) ->
        expect(flat).to.deep.equal
          DEBUG           : ""
          DEPLOY_ENV      : "production"
          MYAPP_REDIS_HOST: "127.0.0.1"
          MYAPP_REDIS_PASS: ""
          NODE_APP_PREFIX : "MYAPP"
          NODE_ENV        : "production"
          SUBDOMAIN       : "mycompany-myapp"
        done()
