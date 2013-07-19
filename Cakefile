{spawn, exec} = require 'child_process'

task 'dev', 'continually build', ->
    coffee = spawn 'coffee', ['-m', '-cw', '-o', 'js', 'src']
    coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
    #uncomment these if you're not running off of rails /public
    # static_here = spawn 'static-here'
    # static_here.stdout.on 'data', (data) -> console.log data.toString().trim()