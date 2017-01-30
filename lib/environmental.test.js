'use strict';

var should = require('chai').should();

var _require = require('chai'),
    expect = _require.expect;

var Environmental = require('../src/environmental');

describe('Environmental', function () {
  describe('config', function () {
    it('should be config and lowercases', function (done) {
      var config = Environmental.config({ MYAPP_REDIS_HOST: '127.0.0.1' }, 'MYAPP');

      expect(config).to.deep.equal({
        redis: {
          host: '127.0.0.1'
        }
      });
      return done();
    });

    it('should default to process.env and be able to find the HOME env var', function (done) {
      var config = Environmental.config();
      expect(config).to.have.ownProperty('home');
      return done();
    });

    it('should allow to disable filtering via false', function (done) {
      var config = Environmental.config({
        parent: {
          child: '1'
        }
      }, false);
      expect(config).to.have.ownProperty('parent');
      return done();
    });

    it('should support the convenience shortcut', function (done) {
      var config = require('../src/environmental').config({
        'PARENT_CHILD': '1' });
      expect(config).to.deep.equal({
        parent: {
          child: '1'
        }
      });
      return done();
    });

    return it('should be able handle travis environment', function (done) {
      var config = require('../src/environmental').config({
        travis: 'true',
        travis_build_dir: '/home/travis/build/kvz/environmental'
      });

      expect(config).to.deep.equal({
        travis: {
          build: {
            dir: '/home/travis/build/kvz/environmental'
          }
        }
      });
      return done();
    });
  });

  return describe('capture', function () {
    it('should be able to capture production.sh and ignore MYAPP_REDIS_PORT', function (done) {
      var env = new Environmental({
        ignore: ['MYAPP_REDIS_PORT', 'PWD', 'SHLVL', '_'] });
      env.capture(__dirname + '/../envs/production.sh', function (err, flat) {
        expect(err).to.be.null;
        expect(flat).to.deep.equal({
          DEBUG: '',
          DEPLOY_ENV: 'production',
          MYAPP_REDIS_HOST: '127.0.0.1',
          MYAPP_REDIS_PASS: '',
          NODE_APP_PREFIX: 'MYAPP',
          NODE_ENV: 'production',
          SUBDOMAIN: 'mycompany-myapp'
        });
        return done();
      });
    });

    return it('should capture environemtn without defining an ignore', function (done) {
      var env = new Environmental();
      env.capture(__dirname + '/../envs/production.sh', function (err, flat) {
        expect(err).to.be.null;
        expect(flat).to.deep.equal({
          DEBUG: '',
          DEPLOY_ENV: 'production',
          MYAPP_REDIS_HOST: '127.0.0.1',
          MYAPP_REDIS_PORT: '6379',
          MYAPP_REDIS_PASS: '',
          NODE_APP_PREFIX: 'MYAPP',
          NODE_ENV: 'production',
          SUBDOMAIN: 'mycompany-myapp'
        });
        return done();
      });
    });
  });
});
//# sourceMappingURL=environmental.test.js.map