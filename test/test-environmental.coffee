should        = require("chai").should()
expect        = require("chai").expect
Environmental = require "../src/environmental"
environmental = new Environmental

describe "nested", ->
  it "should be nested", (done) ->
    nested = environmental.nested
      MYAPP_REDIS_HOST: "127.0.0.1",
    , "MYAPP"

    expect(nested).to.deep.equal
      redis:
        host: "127.0.0.1"
    done()
