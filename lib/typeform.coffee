# Description:
#   Integrate typeform with hubot!
#
# Dependencies:
#   "jquery": "^2.1.3"
#   "request": "^2.55.0"
#   "underscore": "^1.8.3"
#
# Configuration:
#   HUBOT_TYPEFORM_KEY - typeform application key
#
# Commands:
#   hubot typeform create <survey_form_link> - Create a new Survey
#   hubot typeform list "<survey_name>" - Show surveys you created
#   hubot typeform publish <survey_name> <user_list_link> - Publish your survey to specific users
#
#
# Author:
#   changlong.wu
#   yiqing.zhu
#   zewei.xia

survey = {}
users = {}

TYPEFORM_URL ="https://api.typeform.io/v0.1/forms"
PASTE_URL = "https://paste.dev-jpe1.rakuten.rpaas.net/raw"

API_KEY = process.env.HUBOT_TYPEFORM_KEY

BRAIN_TYPEFORM_KEY = "typeform"

_ = require("underscore")
request = require("request")
jsonlint = require("jsonlint")

# verify that all the environment vars are available
checkConfig = (msg) ->
  msg.reply "Error: HUBOT_TYPEFORM_KEY is not specified" if not API_KEY
  return

module.exports = (robot) ->

  robot.brain.data[BRAIN_TYPEFORM_KEY] = "{}"

  robot.respond /typeform create(.*)/i, (msg) ->
    checkConfig msg
    survey_link = msg.match[1]

    if survey_link.length == 0
      msg.send "Command : typeform create <surveylink>."
      msg.send "You must provide a survey link."
      msg.send "If you do not know how to make one."
      msg.send "Please refer #{PASTE_URL}/mumihocima.json"
      return

    # TODO Check if user_link

    # Handle survey link 
    # Maybe a full link, maybe a short name
    # For example
    # Correct : https://paste.dev-jpe1.rakuten.rpaas.net/raw/mumihocima.json
    # Need to change : https://paste.dev-jpe1.rakuten.rpaas.net/mumihocima.json
    # Need to change : mumihocima.json
    #handle_survey_link

    msg.reply "Analynizing survey data..."

    # Handle survey data
    get_survey survey_link, (data) ->
      try

        # Check if it is a json data
        survey = jsonlint.parse(data)
      catch e
        msg.send "The survey data you provided is not correct."
        msg.send "Content is :"
        msg.send "--------------------"
        msg.send data
        msg.send "--------------------"
        msg.send e
        return

      msg.reply "Correct. I will create a new survey for you."

      # create a typeform
      create_typeform survey, (data) ->

        # TODO analyze data details   webhook
        typeform_link = data.links.form_render.get

        # Save into hubot brain
        formlist = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])

        # TODO change title to user.name
        formlist[data.title] = typeform_link
        robot.brain.data[BRAIN_TYPEFORM_KEY] = JSON.stringify(formlist)

        msg.reply "Ok. Survey creation finished. You can access it through : #{typeform_link}"


  robot.respond /typeform preivew/i, (msg) ->
    checkConfig msg
    msg.reply "Command : typeform preview"

    # Get from hubot brain
    typeforms = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])
     if typeforms[user.name]
       msg.reply "Please copy this link : #{typeforms[key]}"
     else
       msg.reply "Nope. Please create your own typeform."

  robot.respond /typeform publish(.*)/i, (msg) ->
    checkConfig msg
    users_list = msg.match[1]

    if user_list.length == 0
      msg.send "Command : typeform publish <surveyname>."
      msg.send "You must provide a survey name."
      msg.send "Survey name can be found through typeform list command."

    msg.reply "Analynizing user list."
    # Handle survey data
    get_users users_link, (data) ->

      # TODO specify '\n', ',' ';'
      # Rejext any others and notify
      users = data.split('\n')

      msg.reply "Correct. I will publish the survey for you."

      # create rooms for users to take the survey
      # TODO

get_survey = (link, callback) ->
  get link, callback

create_typeform = (data, callback) ->
  link = TYPEFORM_URL
  ops = {
    json: data,
    headers: 'X-API-TOKEN': API_KEY
  }
  post link, ops, callback

# http get
get = (link, callback) ->
  request link, (error, response, body) ->
    callback(body)

# http post
post = (link, ops, callback) ->
  request.post link, ops, (error, response, body) ->
    callback(body)
