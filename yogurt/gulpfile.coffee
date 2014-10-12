fs = require 'fs'
gulp = require 'gulp'
yaml = require 'js-yaml'
plugins = require("gulp-load-plugins")()

config = yaml.load(fs.readFileSync("config.yml", "utf8"))

gulp.task 'connect', ->
  plugins.connect.server
    root: config.webserver.root_path
    port: config.webserver.port
    livereload: true

gulp.task 'jade-develop', ->
  gulp.src config.paths.jade.src
    .pipe plugins.jade
      pretty: true
    .pipe gulp.dest config.paths.jade.develop_compile
    .pipe plugins.connect.reload()

gulp.task 'watch', ->
  gulp.watch config.paths.jade.src, ['jade-develop']
  return

gulp.task 'default', [
  'connect'
  'watch'
]
