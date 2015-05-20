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

COMMAND_SHORTCUT =
  'h': 'help'
  'c': 'create'
  'pub': 'public'
  'pre': 'preview'
  'w': 'watch'

TYPEFORM_URL ="https://api.typeform.io/v0.1/forms"
PASTE_URL = "https://paste.dev-jpe1.rakuten.rpaas.net/raw"
STATISTICS_URL = "http://128.199.175.201/api/hubot/"

API_KEY = process.env.HUBOT_TYPEFORM_KEY

BRAIN_TYPEFORM_KEY = "typeform"

HIPCHAT_API = "https://api.hipchat.com/v2"
HIPCHAT_TOKEN = "roHqrGYG0klkFIqkOoAGZNlcxU2La8OACB4vIc08"

COUNT_API = "http://128.199.175.201/api/hubot/"

_ = require("underscore")
request = require("request")
jsonlint = require("jsonlint")

# verify that all the environment vars are available
checkConfig = (msg) ->
  msg.reply "Error: HUBOT_TYPEFORM_KEY is not specified" if not API_KEY
  return

module.exports = (robot) ->

  robot.brain.data[BRAIN_TYPEFORM_KEY] = "{}"

  get_jid_of_hipchat_user = (rakuten_email, callback) ->
    get_ex "#{HIPCHAT_API}/user/#{rakuten_email}?auth_token=#{HIPCHAT_TOKEN}", (error, result) ->
      res_obj = jsonlint.parse(result)
      if error == null
        callback null, res_obj.xmpp_jid
      else
        callback error

  get_answer_count = (uid, callback) ->
    get_ex "#{COUNT_API}", (error, result) ->
      res_obj = jsonlint.parse(result)
      if error == null
        if uid of res_obj
          callback null, res_obj[uid].count
        else
          callback null, 0
      else
        callback error
  get_users = (link, callback) ->
    get link, callback

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

  # http get
  get_ex = (link, callback) ->
    request link, (error, response, body) ->
      callback error, body

  robot.hear /^(?:\/tf|typeform) ?([^ ]+ ?[^ ]*)?/i, (msg) ->
    checkConfig msg
    match_string = 'help'

    if undefined != msg.match[1]
      match_string = msg.match[1]

    command_opts = match_string.split(' ')
    command = command_opts[0]
    opt = command_opts[1]

    if command == undefined
      command = 'help'

    for short_cut of COMMAND_SHORTCUT
      if command == short_cut
        command = COMMAND_SHORTCUT[short_cut]
        break

    switch command
      when 'create'    then create msg, opt
      when 'publish'   then publish msg, opt
      when 'preview'   then preview msg, opt
      when 'watch'     then watch msg, opt
      else
        help msg


  help = (msg) ->
    msg.send "Hello there. Welcome Typeform Hubot. *_*"
    msg.send "I am still a young robot, please be nice to me."
    msg.send "\n"
    msg.send "Usage: typeform | /tf command <args>"
    msg.send "/tf is short for typeform"
    msg.send "\n"
    msg.send "create | c\t<surveylink>\tCreate your own typeform. c is short for create"
    msg.send "preview | pre\t\t\tPreview your typeform link. pre is short for preview"
    msg.send "publish | pub\t<userlink>\tPublish your typeform to users. pub is short for publish"
    msg.send "\n"
    msg.send "Typeform : Ask awesomely."
    msg.send "Typeform is a service aims to help users create attractive online forms and surveys that people will be encouraged to answer."
    msg.send "Take a tour : https://forms.typeform.io/to/ihTVhvReksgW9w"

  create = (msg, opt) ->
    checkConfig msg
    survey_link = opt
    user = msg.message.user
    if !survey_link or survey_link.length == 0
      msg.send "Command : typeform create <surveylink>."
      msg.send "You must provide a survey link."
      msg.send "If you do not know how to make one."
      msg.send "Please refer example : #{PASTE_URL}/araqawanah.json"
      msg.send "What's inside json? Please refer : http://docs.typeform.io/v0.2/docs/introduction"
      return

    if not validateURL survey_link
      msg.send "Command : typeform create <surveylink>."
      msg.send "<surveylink> should be a valide URL"
      return

    # TODO Check if user_link

    # Handle survey link
    # Maybe a full link, maybe a short name
    # For example
    # Correct : https://paste.dev-jpe1.rakuten.rpaas.net/raw/mumihocima.json
    # Need to change : https://paste.dev-jpe1.rakuten.rpaas.net/mumihocima.json
    # Need to change : mumihocima.json
    #handle_survey_link

    msg.reply "Analyzing survey data..."

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

      # Add webhook submit url field
      survey['webhook_submit_url'] = STATISTICS_URL

      # create a typeform
      create_typeform survey, (data) ->

        # TODO analyze data details   webhook
        typeform_link = data.links.form_render.get
        statistics_link = data.webhook_submit_url
        uid = data.id

        # Save into hubot brain
        formlist = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])

        # TODO change title to user.name
        formlist[user.name] = {
          "typeform_link": typeform_link,
          "statistics_link": statistics_link,
          "uid": uid,
          "count": 0
        }
        robot.brain.data[BRAIN_TYPEFORM_KEY] = JSON.stringify(formlist)

        msg.reply "Ok. Survey creation finished."
        msg.reply "To see typeform preview. Please click : #{typeform_link}"
        msg.reply "To see survey statistics. Please click : #{statistics_link}"

  publish = (msg, opt) ->
    user = msg.message.user
    # TODO if has unpublished form
    forms = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])

    if not (user.name of forms)
      msg.reply "Nope. Please create your own typeform."
      msg.reply "Usage : typeform create <surveylink> Create your own typeform"
      return

    form_link = forms[user.name]['typeform_link']

    users_link = opt

    if !users_link or users_link.length == 0
      msg.send "Command : typeform publish <userslink>."
      msg.send "You must provide a user list."
      msg.send "Please refer example : #{PASTE_URL}/seqiqikeje.list"
      return

    if not validateURL users_link
      msg.send "Command : typeform publish <userslink>."
      msg.send "<userslink> should be a valide URL"
      return

    msg.reply "Analynizing user list..."

    # Handle survey data
    get_users users_link, (data) ->

      # TODO specify '\n', ',' ';'
      # Rejext any others and notify
      users = data.split('\n')

      msg.reply "Correct. I will publish the survey for you."

      for user_email in users
        do (user_email) ->
          msg.reply "Notifying #{user_email}"
          get_jid_of_hipchat_user user_email, (error, jid) ->
            if error != null
              msg.reply "Get error #{error}"
            else
              robot.messageRoom jid, "Hi, #{user.name} create a survey for you #{form_link}"
    return

  preview = (msg, opt) ->
    msg.reply "Typeform previewing ..."
    user = msg.message.user
    # Get from hubot brain
    typeforms = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])
    if typeforms[user.name]
      msg.reply "Please copy this link : #{typeforms[user.name]["typeform_link"]}"
    else
      msg.reply "Nope. Please create your own typeform."
      msg.reply "Command : typeform create <survey_link>."

  watch   = (msg, opt) ->
    msg.reply "Typeform watching ..."
    user = msg.message.user
    # Get from hubot brain
    typeforms = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])
    if typeforms[user.name]
      msg.reply "Please copy this link to watch current statistics : #{typeforms[user.name]["statistics_link"]}"
      uid = typeforms[user.name]["uid"]
      setInterval (->
        typeforms = jsonlint.parse(robot.brain.data[BRAIN_TYPEFORM_KEY])
        get_answer_count uid, (error, count) ->
          if error == null
            pre_count = typeforms[user.name]['count']
            if count > pre_count
              msg.reply "Got #{count - pre_count} new answer(s)."
              typeforms[user.name]['count'] = count
              robot.brain.data[BRAIN_TYPEFORM_KEY] = JSON.stringify(typeforms)
        return
      ), 2000

    else
      msg.reply "Nope. Please create your own typeform."
      msg.reply "Command : create <survey_link>."


validateURL = (textval) ->
  urlregex = new RegExp('^(http|https|ftp)://([a-zA-Z0-9.-]+(:[a-zA-Z0-9.&amp;%$-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]).(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0).(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0).(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9-]+.)*[a-zA-Z0-9-]+.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(:[0-9]+)*(/($|[a-zA-Z0-9.,?\'\\+&amp;%$#=~_-]+))*$')
  urlregex.test textval
