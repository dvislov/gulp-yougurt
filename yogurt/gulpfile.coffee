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


# Templates compilation

gulp.task 'jade-develop', ->
  gulp.src config.paths.jade.src
    .pipe plugins.plumber()
    .pipe plugins.jade
      pretty: true
    .pipe plugins.duration('jade develop templates')
    .pipe gulp.dest config.paths.jade.develop_compile
    .pipe plugins.connect.reload()

gulp.task 'jade-production', ->
  gulp.src config.paths.jade.src
    .pipe plugins.plumber()
    .pipe plugins.jade
      pretty: false
    .pipe plugins.duration('jade production templates')
    .pipe gulp.dest config.paths.jade.develop_production


# Styles compilation

gulp.task 'sass-develop', ->
  gulp.src config.paths.sass.src
    .pipe plugins.plumber()
    .pipe plugins.rubySass()
    .pipe plugins.autoprefixer()
    .pipe plugins.duration('sass develop compilation')
    .pipe gulp.dest config.paths.sass.develop_compile
    .pipe plugins.connect.reload()

gulp.task 'watch', ->
  gulp.watch config.paths.jade.src, ['jade-develop']
  gulp.watch config.paths.jade.src_shared, ['jade-develop']
  gulp.watch config.paths.sass.base, ['sass-develop']
  return

gulp.task 'default', [
  'connect'
  'watch'
]

gulp.task 'production', [
  'jade-production'
]
