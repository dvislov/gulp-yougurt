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

gulp.task 'sass-production', ->
  gulp.src config.paths.sass.src
    .pipe plugins.plumber()
    .pipe plugins.rubySass()
    .pipe plugins.autoprefixer()
    .pipe plugins.csso()
    .pipe plugins.duration('sass production compilation')
    .pipe gulp.dest config.paths.sass.production_compile


# Compile images sprite
spritesmith = require 'gulp.spritesmith'
# TODO: make this require from gulp-load-plugins

gulp.task 'sprite-develop', ->
  spriteData = gulp.src(config.paths.images.sprite.src).pipe(plugins.plumber())
    .pipe plugins.duration('sprite develop compilation')
    .pipe(spritesmith(
      imgName: 'sprite.png'
      cssName: 'sprite.sass'
      imgPath: '../images/sprite.png'
      cssFormat: 'sass'
      padding: 10
      algorithm: 'binary-tree'
    ))

  spriteData.img
    .pipe plugins.plumber()
    .pipe plugins.duration('sprite develop images compilation')
    .pipe gulp.dest config.paths.images.sprite.develop_compile_images
    .pipe plugins.connect.reload()
  spriteData.css
    .pipe plugins.plumber()
    .pipe plugins.duration('sprite develop styles compilation')
    .pipe gulp.dest config.paths.images.sprite.develop_compile_styles
    .pipe plugins.connect.reload()

gulp.task 'sprite-production', ->
  spriteData = gulp.src(config.paths.images.sprite.src).pipe(plugins.plumber())
    .pipe plugins.duration('sprite production compilation')
    .pipe(spritesmith(
      imgName: 'sprite.png'
      cssName: 'sprite.sass'
      imgPath: '../images/sprite.png'
      cssFormat: 'sass'
      padding: 10
      algorithm: 'binary-tree'
    ))

  spriteData.img
    .pipe plugins.plumber()
    .pipe plugins.duration('sprite production images compilation')
    .pipe gulp.dest config.paths.images.sprite.production_compile_images
    .pipe plugins.connect.reload()
  spriteData.css
    .pipe plugins.plumber()
    .pipe plugins.duration('sprite production styles compilation')
    .pipe gulp.dest config.paths.images.sprite.production_compile_styles
    .pipe plugins.connect.reload()


# base64 images
gulp.task 'base64-develop', ->
  gulp.src config.paths.images.base64.develop_src
    .pipe plugins.base64
      baseDir: config.paths.images.base64.base_dir
      extensions: ['gif', 'jpg', 'png']
      debug: true
    .pipe gulp.dest config.paths.images.base64.develop_compile


gulp.task 'watch', ->
  gulp.watch config.paths.jade.src, ['jade-develop']
  gulp.watch config.paths.jade.src_shared, ['jade-develop']
  gulp.watch config.paths.sass.base, ['sass-develop', 'base64-develop']
  gulp.watch config.paths.images.sprite.src, ['sprite-develop', 'sass-develop']
  return

gulp.task 'default', [
  'connect'
  'watch'
]

gulp.task 'production', [
  'jade-production'
  'sprite-production'
  'sass-production'
]
