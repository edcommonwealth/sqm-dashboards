# edcontext

This project contains three pieces:

- A webapp for visualizing and understanding MCIEA survey data
- Tasks for processing and indexing raw survey data
- Experimental work to conduct survey samples via text message

This is a Rails project, deployed on Heroku.

## Site links

Live app: [https://mciea-dashboard.herokuapp.com/](https://mciea-dashboard.herokuapp.com/)
Live dashboard: [http://mciea-dashboard.herokuapp.com/districts/winchester/schools/winchester-high-school/dashboard?year=2020-21](http://mciea-dashboard.herokuapp.com/districts/winchester/schools/winchester-high-school/dashboard?year=2020-21)

## Local development

### Database

This project uses PostgreSQL to store data.

Install Postgres and get it up and running first.

#### Docker

Postgres can be quickly and easily be installed using `docker run`

Simply copy and past the following command into your machine running Docker:

```
docker run --name sqm-postgres -p 5432:5432 -e POSTGRES_PASSWORD=MySuperSecretPassword -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_USER=$USER -v ~/postgres-data:/var/lib/postgresql/data --restart always -d postgres:13
```

Just change `MySuperSecretPassword` to the password you want to use with Postgres, and `~/postgres-data` to the folder where you want to store the database data.

Then, confirm it is running using `docker ps`

```
$ docker ps
│  CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                                       NAMES
│  761a4dddbbc0   postgres:13   "docker-entrypoint.s…"   24 minutes ago   Up 22 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   sqm-postgres
```

#### (MacOS, Optional), you can use Homebrew:

```
brew install postgres
brew services start postgresql
```

#### Linux:

Install postgres. Known working version is version 13

```bash
https://www.postgresql.org/download/
```

On linux, if you run into problems creating the postgres database, edit /etc/postgresql/13/main/pg_hba.conf. Change the connection method of IPv4 and IPv6 connections from `md5` to trust.

```
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
```

Once postgres is installed and running, install the required gems and then migrate the database.

```bash
bundle install
bundle exec rake db:create db:schema:load db:seed
```

Install the javascript dependencies

```bash
yarn install
```

At this point you can run the app and login. There won't be any data yet though; keep reading!

The seed file populates the following tables

| Name        | Description                                                                                                                                                                 |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| School      | School ids are only unique to their district. More than one school has an id of 1                                                                                           |
| District    | Districts and schools have attached slugs. We find search for these models by their slugs                                                                                   |
| SqmCategory | The legacy name here is Category. It still exits in the database. We wanted the freedom to make changes and still preserve the legacy site until the end of the engagement. |
| Measure     | In the bar graph measures represent a single bar                                                                                                                            |
| SurveyItem  | This table has an attribute `prompt` that is the question asked                                                                                                             |

SurveyItemResponses does not get populated at this stage.

### Gems

| Name                | Description                                         |
| ------------------- | --------------------------------------------------- |
| puma                | webserver                                           |
| pg                  | postgres                                            |
| jquery-rails        | legacy, allows use of jquery                        |
| jbuilder            | legacy, build json objects                          |
| haml                | legacy, write views in haml syntax                  |
| bootstrap           | css framework                                       |
| newrelic_rpm        | legacy?, application monitoring                     |
| devise              | authentication                                      |
| omniauth            | authentication                                      |
| twilio-ruby         | legacy, text messaging                              |
| activerecord-import | faster database imports                             |
| stimulus            | Create javascript controllers                       |
| turbo-rails         | Manages what gets rendered on the frontend and when |
| redis               | Caching system                                      |
| jsbundling-rails    | Bundle javascript asssets                           |
| cssbundling-rails   | Bundle css assets                                   |

### External APIs

None yet. Hoping to integrate with Powerschool and Aspen for school administrative data.

### JavaScript

Esbuild is used as the javascript bundler. Scripts for esbuild are defined in package.json e.g. `yarn build`. This script will run if in development with `bin/dev`.
The javascript testing library is jest. Manually run test with `yarn test`. Javascript tests will also run with `bundle exec rake`.

Stimulus is installed. Create a stimulus controller with `./bin/rails generate stimulus [controller]`. If you create a stimulus controller manually, you can add it to `index.js` with the command `stimulus:manifest:update`.

### CSS

Bootstrap 5

## Loading Data

### Loading Survey Item Responses

SurveyItemResponses is the most important table to understand. SurveyItemResponses is the data that will change year to year and makes up the majority of the database records. Roughly 500,000 SurveyItemResponses per year.

Some notes:

- The data loading task assumes that the CSV files live in SFTP servers whose connection strings are stored in the environment
- Data loading assumes the CSVs live in the the `/data/survey_responses/clean` directory. Usually, CSVs are actually stored in a further directory for each academic year.
- The data loading task is idempotent, i.e. it can be run multiple times without duplicating previously-ingested data

How to run the data loading task at the default directory:

```bash
# locally
bundle exec rake data:load_survey_responses

# on heroku staging environment
heroku run:detached -a mciea-beta bundle exec rake data:load_survey_responses

# on heroku production environment
heroku run:detached -a mciea-dashboard bundle exec rake data:load_survey_responses
```

Or if you want to load data from a specific directory

```bash
# locally
SFTP_PATH=/ecp/data/survey_responses/clean/2024_25 bundle exec rake data:load_survey_responses_from_path
# You can also swap the order of the commands and environment variables
bundle exec rake data:load_survey_responses_from_path  SFTP_PATH=/ecp/data/survey_responses/clean/2024_25

# on heroku staging environment
heroku run:detached -a ecp-sqm-dashboard SFTP_PATH=/ecp/data/survey_responses/clean/2024_25 bundle exec rake data:load_survey_responses_from_path

# on heroku production environment
heroku run:detached -a ecp-sqm-dashboard SFTP_PATH=/ecp/data/survey_responses/clean/2024_25 bundle exec rake data:load_survey_responses_from_path
```

For convenience, you can use the following script for loading data on Heroku:

```bash
# on heroku staging environment
./scripts/load_survey_responses_on_heroku ecp-sqm-beta

# on heroku production environment
./scripts/load_survey_responses_on_heroku ecp-sqm-dashboard
```

There is also an example one-off task to load a single csv at a time.

```bash
bundle exec rake one_off:load_2018_19_student_responses
```

### Loading Admin Data Values

Loading admin data is similar to loading survey item responses. Run the one of the following scripts to load admin data to a selected environment.

```bash
# locally
$ bundle exec rake data:load_admin_data

# on heroku staging environment
$ heroku run:detached -a mciea-beta bundle exec rake data:load_admin_data

# on heroku production environment
$ heroku run:detached -a mciea-dashboard bundle exec rake data:load_admin_data
```

### Load enrollment and staffing data

Enrollment and staffing numbers are taken from the DESE website.

To scrape staffing data from dese:

```bash
bundle exec rake scrape:staffing
```

To scrape enrollment data from dese:

```bash
bundle exec rake scrape:enrollment
```

Then to load it, run the seeder:

```bash
bundle exec rake db:seed
```

Or load it remotely on heroku

```bash
heroku run:detached -a mciea-beta bundle exec rake db:seed
```

Or to load it for the lowell dashboard specifically

```bash
bundle exec rake data:seed_only_lowell
```

### Upload cleaned data to SFTP

You can upload cleaned lowell data to the SFTP server with

```bash
bundle exec rake upload:lowell
```

## Generating reports

Some reports can be generated automatically using `bundle exec rake`

For example, to create a survey item report for one school, you can simply run:

```bash
bundle exec rake 'report:survey_item:create[Example School Name, 2023-24]'
```

Or for an entire district:

```bash
bundle exec rake 'report:survey_item:district[District Name, 2023-24]'
```

Other report generation tasks currently available include:

- `report:measure:district[Example District]`
- `report:measure:sqm`
- `report:scale:bll`

Reference `lib/tasks/report.rake` for the all report generation tasks currently available.

## Running tests

### Single threaded test execution

Prepare the test database.

```bash
bundle exec rake db:test:prepare
```

If you need to look at the rails console for the test environment

```bash
RAILS_ENV=test rails c
```

Run the tests

```bash
bundle exec rake
```

### Parallel test execution

The [parallel tests](https://github.com/grosser/parallel_tests) gem is installed. It's optional to use.

Set the `TEST_ENV_NUMBER` environment variable. For example, add this line to your `.bashrc`

```bash
export TEST_ENV_NUMBER="20"
```

Create the additional databases

```bash
bundle exec rake parallel:create
```

Run the tests in parallel

```bash
bundle exec rake parallel:spec
```

Run the tests with a specific number of processes

```bash
bundle exec rake parallel:spec[5]
```

### Viewing test coverage

```
xdg-open coverage/index.html
```

### Javascript tests

Run the javascript tests

```bash
yarn test
```

### Connecting to Heroku git

To add the heroku remote repository for beta run
`git remote add beta	https://git.heroku.com/mciea-beta.git`

To add the heroku remote repository for production run
`git remote add dashboard	https://git.heroku.com/mciea-dashboard.git `

## Continuous Integration

Pushing commits to the main branch triggers auto-deployment to the staging environment.
Use the ship-it script from the main branch when you're ready to deploy to staging

```bash
scripts/ship-it.sh
```

Deployments to production must be done through the Heroku web interface or via the Heroku command line

## Running the development server

Start esbuild for dynamic compilation of javascript assets.

```bash
yarn build --watch
```

Start the puma web server

```bash
bin/rails s
```
