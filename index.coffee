fs = require 'fs'
path = require 'path'

module.exports = (robot, scripts) ->
  scriptsPath = path.resolve(__dirname, 'lib')
  fs.exists scriptsPath, (exists) ->
    return "Missing 'lib' directory! Please make sure you create it." unless exists
    for script in fs.readdirSync(scriptsPath)
      if scripts? and '*' not in scripts
        robot.loadFile(scriptsPath, script) if script in scripts
      else
        robot.loadFile(scriptsPath, script)
