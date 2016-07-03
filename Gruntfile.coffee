module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Browser version building
    browserify:
      options:
        transform: [
          ['coffeeify']
        ]
        browserifyOptions:
          extensions: ['.coffee']
          fullPaths: false
      src:
        files:
          'build/finito.js': ['lib/finito.coffee']
      tests:
        files:
          'build/tests.js': ['test/Machine.coffee']

    yaml:
      schemas:
        files: [
          expand: true
          cwd: 'schema/'
          src: '*.yaml'
          dest: 'schema/'
        ]

    # JavaScript minification for the browser
    uglify:
      options:
        banner: '/* Finito <%= pkg.version %> -
                 Cross-language Finite State Machine.
                 See http://github.com/jonnor/finito for more information. */'
        report: 'min'
      finito:
        files:
          './build/finito.min.js': ['./build/finito.js']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['test/*.coffee']
        options:
          reporter: 'spec'

    # Web server for the browser tests
    connect:
      server:
        options:
          port: 8000

    # BDD tests on browser
    mocha_phantomjs:
      all:
        options:
          output: 'test/result.xml'
          reporter: 'spec'
          urls: ['http://localhost:8000/test/runner.html']

    clean:
      app:
        src: ['build']


  # Grunt plugins used for building
  @loadNpmTasks 'grunt-yaml'
  @loadNpmTasks 'grunt-browserify'
  @loadNpmTasks 'grunt-contrib-uglify'
  @loadNpmTasks 'grunt-contrib-copy'
  @loadNpmTasks 'grunt-contrib-clean'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-mocha-phantomjs'

  @loadNpmTasks 'grunt-exec'

  # Our local tasks
  @registerTask 'build', 'Build Finito for the chosen target platform', (target = 'all') =>
    @task.run 'yaml'
    if target is 'all' or target is 'browser'
      @task.run 'browserify'
      @task.run 'uglify'

  @registerTask 'test', 'Build Finito and run automated tests', (target = 'all') =>
    @task.run 'build'
    if target is 'all' or target is 'nodejs'
      @task.run 'cafemocha'
    if target is 'all' or target is 'browser'
      @task.run 'connect'
      @task.run 'mocha_phantomjs'

  @registerTask 'default', ['test']

