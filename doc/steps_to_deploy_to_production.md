# Deploying to production

* Sign in to heroku
* Back up the database
```
heroku pg:backups:capture
heroku pg:backups:download
```
* Navigate to mciea-dashboard settings tab
* Ensure environmental variables match between staging and production environments
* Navigate to mciea-dashboard deploy tab
* Select branch to deploy(main)
* Verify in the activity log that Heroku builds the deployment
* Verify that the site contains the new features
* Run the db:seed script
* Verify that the data represented on the different tabs matches what is expected.  The items listed in the measure key should be represented on the site.
