
http    = require('http')
express = require('express')
path    = require('path')
favicon = require('serve-favicon')
fs      = require('fs')
yaml    = require('js-yaml')


app           = express()
webserver     = http.createServer(app)
basePath      = path.dirname(require.main.filename)
generatedPath = path.join(basePath, '.generated')
vendorPath    = path.join(basePath, 'bower_components')
faviconPath   = path.join(basePath, 'app', 'favicon.ico')

app.engine('.html', require('hbs').__express)

app.use(favicon(faviconPath))
app.use('/assets', express.static(generatedPath))
app.use('/vendor', express.static(vendorPath))

port = process.env.PORT || 3002
webserver.listen(port)

gh = require('./github.coffee')
gh.getRepos("vikinghug")
setInterval ->
  gh.getRepos("vikinghug")
, 10000

getDataFile = (file) ->
  try
    filepath = path.join(basePath, 'data', file + '.yaml')
    doc = yaml.safeLoad(fs.readFileSync(filepath, 'utf8'))
  catch err
    console.log(err)

contributors = getDataFile('contributors')

app.get '/', (req, res) ->
  res.render(generatedPath + '/index.html', {contributors: contributors, repos: gh.repos})
app.get /^\/(\w+)(?:\.)?(\w+)?/, (req, res) ->
  path = req.params[0]
  ext  = req.params[1] ? "html"
  res.render(basePath + "/.generated/#{path}.#{ext}")



module.exports = webserver