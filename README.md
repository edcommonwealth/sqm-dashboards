# edcontext

This project contains three pieces:
- A webapp for visualizing and understanding MCIEA survey data
- Tasks for processing and indexing raw survey data
- Experimental work to conduct survey samples via text message

This is a Rails project, deployed on Heroku.


## Local development
```
$ bundle install
$ bundle exec rake db:create db:migrate db:seed
```
At this point you can run the app and login.  There won't be any data yet though; keep reading!

## Loading Data
Postgres is the primary data store for the webapp, but the definitions of the questions and measures are stored in `.json` files and raw survey data is stored in `.csv` files.  These are collected offline, and then processed by the rake tasks to load that data into Postgres for use by the webapp.

There are several different kinds of data needed:
- `measures.json`
- `questions.json`
- `student_responses.csv`
- `teacher_responses.csv`

You can load these into the database and index them for use in the webapp by running rake tasks.

You can start by generating fake data:
```
$ bundle exec rake data:generate
```

Loading all the real response data take a while, so you can start by loading only a sample of the data for one particular school with:

```
$ bundle exec rake data:load_sample
```

This loads all the data:

```
$ bundle exec rake data:load
```


## Demo deploy
Get the code and make a new repo without any history.
```
$ mkdir edcos-demo
$ git clone https://github.com/jaredcosulich/edcontext.git
$ cd edcontext
# git co feature/ecos-demo
$ rm -rf .git # remove past git history, which has secrets and response data
$ git init
$ git co -b master
$ git commit -m "Initial demo commit"
```

Make a new Heroku app and deploy:
1. Create a new Heroku app
2. Add Postgres
3. Deploy
4. Run `heroku run rake db:migrate db:seed data:generate`
5. Run `heroku run rails console` and add a demo user (eg, `User.create!(email: 'demo@demo.edcontext.org', password: '123456')`)
5. Try it out!


## Path to open source
- [x] Personal phone numbers in code - these are removed (`seed.rb`)
- [x] API keys in code - these are removed (`attempts_controller.rb`)
- [x] Create generator task for demo site
- [x] Remove .csv responses
- [ ] `target_group` in questions aren't set

## Data
Loading attempts took a while.  I factored data rake task out into Ruby class to call methods more directly, and then added whitelist option for importing only data for a particular school.  I used the Vinson school as my test case.


## Making site navigable
- loading data - uncomment and split to bulk
- creating new admin user manually
- moving `#verify_super_admin` to `application_controller`, adding it for `/admin` pages
- `welcome/index.html.haml` to remove commented code and require login
- Login goes to `/user`, add in link to home page there
- Moved seed code into `pilot_parent_test.rake`, removed individual names and phone numbers
- Added `recipients` and `recipient_lists` links to `school/show.html.haml`
- Added `import` link to `recipients` page
- Added `index` action and view for school schedules
- Edit questions without school_id
- Deleted API keys and numbers in `attempts_controller.rb`


## Other Issues
- can't get categories pages to show questions
- looks like computation is inverted for some questions like `http://localhost:3000/schools/vinson-owen-elementary-school/categories/student-emotional-safety`
- back link not working editing schools and districts
- superadmin is done by user id
- no schools for default user?
- endpoints for school/categories, school/questions
- attempts route and controller commented out