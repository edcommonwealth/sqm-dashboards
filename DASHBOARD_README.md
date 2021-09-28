# EDCONTEXT

Displays graphs representing school quality measures.

## Site links

Live app: [https://mciea-dashboard.herokuapp.com/](https://mciea-dashboard.herokuapp.com/)
Live dashboard: [http://mciea-dashboard.herokuapp.com/districts/winchester/schools/winchester-high-school/dashboard?year=2020-21](http://mciea-dashboard.herokuapp.com/districts/winchester/schools/winchester-high-school/dashboard?year=2020-21)

## Techologies

This is a rails project, deployed on Heroku

### Database
Postgres

### Gems

| Name         | Description                        |
| ------------ | ---------------------------------- |
| puma         | webserver                          |
| pg           | postgres                           |
| sassc-rails  | sass compiler                      |
| jquery-rails | legacy, allows use of jquery       |
| jbuilder     | legacy, build json objects         |
| haml         | legacy, write views in haml syntax |
| bootstrap    | css framework                      |
| newrelic_rpm             | legacy?, application monitoring                                    |
| devise | authentication  |
| omniauth | authentication |
| twilio-ruby | legacy, text messaging  |
| activerecord-import | faster database imports |

### External APIs

None yet.  Hoping to integrate with Powerschool and Aspen for school administrative data.


### Javascript libraries

None yet

### css
Bootstrap 5

## Local development
```bash
bundle install
bundle exec rake db:create db:migrate db:seed
```
At this point you can run the app and login.  There won't be any data yet though; keep reading!
The seed file populates the following tables

| Name         | Description                        |
| ------------ | ---------------------------------- |
| School | School ids are only unique to their district.  More than one school has an id of 1 |
| District | Districts and schools have attached slugs.  We find search for these models by their slugs |
| SqmCategory | The legacy name here is Category.  It still exits in the database.  We wanted the freedom to make changes and still preserve the legacy site until the end of the engagement. |
| Measure | In the bar graph measures represent a single bar |
| SurveyItem | This table has an attribute `prompt` that is the question asked |


SurveyItemResponses does not get populated at this stage.  

## Loading Data

This is the most important table to understand.

SurveyItemResponses is the data that will change year to year and makes up the majority of the database records.  Roughly 150,000 SurveyItemResponses per year.  

```bash
# locally
bundle exec rake data:load_survey_responses

# on heroku staging environment
heroku run -a mciea-beta rake data:load_survey_responses

# on heroku production environment
heroku run -a mciea-dashboard rake data:load_survey_responses
```


## Continuous Integration

Pushing commits to the main branch triggers auto-deployment to the staging environment.  

Deployments to production must be done through the Heroku web interface or via the Heroku command line

## Testing

Prepare the test database.

```bash
bundle exec rake db:test:prepare
```

If you need to look at the rails console for the test environment
```bash
RAILS_ENV=test rails c
```

Run tests

```bash
bundle exec rake

#or
rspec

# single file
rspec spec/presenters/measure_graph_row_presenter_spec.rb
#output: 20 examples, 0 failures

# start test from any line
rspec spec/presenters/measure_graph_row_presenter_spec.rb:84
# output: 4 examples, 0 failures
```
