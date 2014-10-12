fs = require 'fs'
yaml = require 'js-yaml'

connect = require 'gulp-connect'

gulp = require 'gulp'
jade = require 'gulp-jade'

config = yaml.load(fs.readFileSync("config.yml", "utf8"))

gulp.task 'connect', ->
  connect.server
    root: config.webserver.root_path
    port: config.webserver.port
    livereload: true

gulp.task 'default', [
  'connect'
]

gulp.task 'jade', ->
  gulp.src '../src/templates/*.jade'
    .pipe jade
      pretty: true
    .pipe gulp.dest '../develop/'

