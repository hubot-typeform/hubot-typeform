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

TYPEFORM_URL ="https://api.typeform.io/v0.1/forms/"
PASTE_URL = "https://paste.dev-jpe1.rakuten.rpaas.net/"

API_KEY = process.env.HUBOT_TYPEFORM_KEY

_ = require("underscore")
request = require("request")

# verify that all the environment vars are available
checkConfig = (out) ->
  out "Error: Typeform app key is not specified" if not process.env.HUBOT_TYPEFORM_KEY
  return false unless (process.env.HUBOT_TYPEFORM_KEY ) 
  true

module.exports = (robot) ->
  # fetch our survey data when the script is loaded
  checkConfig console.log

  robot.respond /typeform create (.*)/i, (msg) ->
    checkConfig msg.send
    survey_link = msg.match[1]

    if survey_link.length == 0
      msg.reply "You must provide a survey link."
      msg.reply "If you do not know how to make one."
      msg.reply "Please refer #{PASTE_URL}/mumihocima.json"
      return

    msg.reply "Analynizing survey data..."


  robot.respond /typeform list/i, (msg) ->
    msg.reply "..."

  robot.respond /typeform publish (.*)/i, (msg) ->
    user_lsit = msg.match[1]
    msg.reply "Analynizing user list."

