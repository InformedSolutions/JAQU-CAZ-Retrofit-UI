## Retrofitted Vehicles Uploader

### Generating documentation

To generate code documentation download the project and install rails dependencies.

```
rails clobber_rdoc  # Remove RDoc HTML files
rails rdoc          # Build RDoc HTML files
rails rerdoc        # Rebuild RDoc HTML files
```

To run the documentation open `doc/app/index.html` in browser.

### Dependencies
* Ruby 2.7
* Ruby on Rails 6
* [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
* Other packages listed in Gemfile and package.json files.

### RSpec test
```
rspec
```

### Cucumber test
```
cucumber
```

### Linting
A Ruby static code analyzer and formatter.
```
rubocop
```

Configurable tool for writing clean, consistent SCSS.
```
scss-lint app/javascript
```

### SonarQube inspection
```
sonar-scanner
```

### Variables

* Create .env configuration file from example config.
```
cp .env.example .env
```

* Enter local credentials for database, google analytics etc.:
```
nano .env
```
