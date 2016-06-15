# PostgreSQL PHP scaffolder

This project generates PHP code from a PostgreSQL database.

# Database Assumptions

* Every table has an "id" column as its primary key
* All the foreign keys are properly defined

# Usage

* Install Ruby
* Install dependencies

```
bundle install
```

* Update config/database.yml with the proper credentials
* Execute the script

```
ruby psql-php-scaffold.rb thedatabasename
```

# Known issues and limitations

* Not scalable : n+1 queries on the associations

