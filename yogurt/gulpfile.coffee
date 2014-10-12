fs = require 'fs'
yaml = require 'js-yaml'

gulp = require 'gulp'
jade = require 'gulp-jade'

config = yaml.load(fs.readFileSync("config.yml", "utf8"))

gulp.task 'default', ->
  console.log "It's gulp, bitch!"
  console.log config.test.sub

gulp.task 'jade', ->
  gulp.src '../src/templates/*.jade'
    .pipe jade
      pretty: true
    .pipe gulp.dest '../develop/'

