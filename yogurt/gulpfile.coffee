gulp = require('gulp')
jade = require('gulp-jade')

gulp.task 'default', ->
  console.log "It's gulp, bitch!"

gulp.task 'jade', ->
  gulp.src '../src/templates/*.jade'
    .pipe jade
      pretty: true
    .pipe gulp.dest '../develop/'

