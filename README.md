[![CI](https://github.com/espoo-dev/rails_boilerplate/actions/workflows/ci.yml/badge.svg)](https://github.com/espoo-dev/rails_boilerplate/actions/workflows/ci.yml)

## Requirements

- Docker
- Docker-compose

## Getting Started

- create a .env file based on .env.example and copy the content of .env.example to .env (`$ cp .env.example .env`)
- run `docker compose build`
- run `docker compose up -d`
- run `docker compose exec web bin/setup`
- run `bin/dev`
- visit http://localhost:3000/

## Run tests

- docker compose exec web bundle exec bin/rspec -P ./_/\*\*/_\_spec.rb (-P ./_/\*\*/_\_spec.rb is needed to run specs from packs)
- open coverage/index.html (Check coverage report)

Observation: To run tests with paper trail versioning, you must use `, versioning: true` on tests describes or use `with_versioning` block bellow:

```ruby
 with_versioning do
    it 'within a `with_versioning` block it will be turned on' do
      expect(PaperTrail).to be_enabled
    end
  end
```

## Check lint

- docker compose exec web bundle exec bin/lint

## Check Security Vulnerabilities

- docker compose exec web bundle exec bin/scan

## Sidekiq

- http://localhost:3000/sidekiq/

Observation: Every time that a new job is created, the server should be stopped and sidekiq image needs to be re-build, to perform that run the followed commands:

- docker compose stop
- docker compose up --build

## Contributing

We encourage you to contribute to [rails_boilerplate](https://github.com/espoo-dev/rails_boilerplate)! Please check out the [Contributing to rails_boilerplate guide](https://github.com/espoo-dev/rails_boilerplate/blob/master/CONTRIBUTING.md) for guidelines about how to proceed.
