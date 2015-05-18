hubot-typeform
============

Integrate typeform with hubot


## Installation

Add **hubot-typeform** to your `package.json` file:

```json
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-scripts": ">= 2.4.2",
  "hubot-typeform": "*"
}
```


Add **hubot-typeform** to your `external-scripts.json`:

```json
["hubot-typeform"]
```

Run `npm install`


## Configuration

```
API_KEY    - Typeform application key
```

- To get your key, go to: `http://typeform.io/`
- For detail docs of typeform, go to: `http://docs.typeform.io/`

## Sample Interaction

```
Manager> hubot typeform create <example_survey_link>
Hubot> Analynizing survey data...
Hubot> Correct. I will create a new survey for you.
Hubot> Ok. Survey creation finished. You can access through : https://clongbupt.typeform.com/to/hV2Qni
Manager> hubot typeform list
Hubot> * <surveyname> - <surveylinke>
Hubot> * <surveyname> - <surveylinke>
Hubot> * <surveyname> - <surveylinke>
user1> hubot publish <surveyname> <user_list_link>
Hubot> Analynizing user list...
HUbot> Correct. <survey_name> publishing...
Hubot> * <user_name> received
Hubot> * <user_name> received
Hubot> * <user_name> received
Hubot> * <user_name> received
Hubot> Done
```


