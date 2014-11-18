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

gulp.task 'jade', ->
  gulp.src config.paths.jade.src
    .pipe plugins.plumber()
    .pipe plugins.jade
      pretty: true
    .pipe plugins.duration('jade templates compile')
    .pipe gulp.dest config.paths.jade.develop_compile
    .pipe plugins.connect.reload()


# Styles compilation

gulp.task 'stylus', ->
  gulp.src config.paths.stylus.src
    .pipe plugins.plumber()
    .pipe plugins.stylus()
    .pipe plugins.autoprefixer()
    .pipe plugins.duration('stylus compilation')
    .pipe gulp.dest config.paths.stylus.develop_compile
    .pipe plugins.connect.reload()


# Compile images sprite
spritesmith = require 'gulp.spritesmith'
# TODO: make this require from gulp-load-plugins

gulp.task 'sprite', ->
  spriteData = gulp.src(config.paths.images.sprite.src).pipe(plugins.plumber())
    .pipe plugins.duration('sprite develop compilation')
    .pipe plugins.plumber()
    .pipe(spritesmith(
      imgName: 'sprite.png'
      cssName: 'sprite.styl'
      imgPath: '../images/sprite.png'
      cssFormat: 'stylus'
      padding: 10
      algorithm: 'binary-tree'
    ))

  spriteData.img
    .pipe plugins.plumber()
    .pipe plugins.duration('sprite images compilation')
    .pipe gulp.dest config.paths.images.sprite.develop_compile_images
    .pipe plugins.connect.reload()
  spriteData.css
    .pipe plugins.plumber()
    .pipe plugins.duration('sprite styles compilation')
    .pipe gulp.dest config.paths.images.sprite.develop_compile_styles
    .pipe plugins.connect.reload()


# copy static assets
gulp.task 'copy-static-images-develop', ->
  gulp.src config.paths.images.static.src
    .pipe gulp.dest config.paths.images.static.develop


gulp.task 'watch', ->
  gulp.watch config.paths.jade.src, ['jade']
  gulp.watch config.paths.jade.src_shared, ['jade']
  gulp.watch config.paths.stylus.base, ['stylus']
  gulp.watch config.paths.images.sprite.src, ['sprite', 'stylus']
  gulp.watch config.paths.images.static.src_path, ['copy-static-images-develop']
  return

gulp.task 'default', [
  'connect'
  'watch'
]

gulp.task 'assets-develop', [
  'copy-static-images-develop'
]

gulp.task 'production', []
