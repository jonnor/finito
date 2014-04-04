module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # CoffeeScript compilation
    coffee:
      libraries:
        expand: true
        cwd: 'lib/js'
        src: ['**.coffee']
        dest: 'build/'
        ext: '.js'

      test:
        options:
          bare: true
        expand: true
        cwd: 'test'
        src: ['**.coffee']
        dest: 'test'
        ext: '.js'

    # Browser version building
    component:
      install:
        options:
          action: 'install'

    component_build:
      finito:
        output: './build/'
        config: './component.json'
        scripts: true
        styles: false
        plugins: ['coffee']
        configure: (builder) ->
          # Enable Component plugins
          json = require 'component-json'
          builder.use json()


    combine:
      browser:
        input: 'build/finito.js'
        output: 'build/finito.js'
        tokens: [
          token: '.coffee"'
          string: '.js"'
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
        src: ['test/*.js']
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
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-component'
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'
  @loadNpmTasks 'grunt-combine'
  @loadNpmTasks 'grunt-contrib-copy'
  @loadNpmTasks 'grunt-contrib-clean'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-mocha-phantomjs'

  @loadNpmTasks 'grunt-exec'

  # Our local tasks
  @registerTask 'build', 'Build Finito for the chosen target platform', (target = 'all') =>
    @task.run 'coffee'
    if target is 'all' or target is 'browser'
      @task.run 'component'
      @task.run 'component_build'
      @task.run 'combine'
      @task.run 'uglify'

  @registerTask 'test', 'Build Finito and run automated tests', (target = 'all') =>
    @task.run 'coffee'
    if target is 'all' or target is 'nodejs'
      @task.run 'cafemocha'
    if target is 'all' or target is 'browser'
      @task.run 'connect'
      @task.run 'component'
      @task.run 'component_build'
      @task.run 'combine'
      @task.run 'mocha_phantomjs'

  @registerTask 'default', ['test']

