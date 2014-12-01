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

  stylusFilter = plugins.filter('*.styl')
  cssFilter = plugins.filter('*.css')

  gulp.src [config.paths.stylus.src, config.paths.vendor.css.src]
    .pipe cssFilter
    .pipe plugins.concat('vendor.css')
    .pipe cssFilter.restore()

    .pipe stylusFilter
    .pipe plugins.stylus()
    .pipe plugins.autoprefixer()
    .pipe plugins.concat('stylus.css')
    .pipe stylusFilter.restore()

    .pipe plugins.duration('stylus compilation')
    .pipe plugins.plumber()

    .pipe gulp.dest config.paths.stylus.develop_compile

gulp.task 'styles-pipeline', ->
  gulp.src [config.paths.vendor.css.concat, config.paths.stylus.compile]
    .pipe plugins.concat('application.css')
    .pipe plugins.duration('stylus + vendor compilation')
    .pipe plugins.plumber()
    .pipe gulp.dest config.paths.stylus.develop_compile

gulp.task 'remove-tmp-styles', ->
  gulp.src [config.paths.vendor.css.concat, config.paths.stylus.compile]
    .pipe plugins.clean
      force: true


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

# CoffeeScript
gulp.task 'coffee', ->
  gulp.src config.paths.coffee.src
  .pipe plugins.coffee()
  .pipe plugins.plumber()
  .pipe plugins.duration('coffeescript compilation')
  .pipe gulp.dest config.paths.coffee.dest
  .pipe plugins.connect.reload()

gulp.task 'watch', ->
  gulp.watch config.paths.jade.src, ['jade']
  gulp.watch config.paths.jade.src_shared, ['jade']

  gulp.watch config.paths.stylus.base, ['stylus', 'styles-pipeline', 'remove-tmp-styles']
  gulp.watch config.paths.images.sprite.src, ['sprite', 'stylus', 'styles-pipeline', 'remove-tmp-styles']
  gulp.watch config.paths.vendor.css.src, ['stylus', 'styles-pipeline', 'remove-tmp-styles']

  gulp.watch config.paths.coffee.watch, ['coffee']
  return

gulp.task 'default', [
  'connect'
  'watch'
]

gulp.task 'production', []
