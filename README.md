Fetch/update gitlab repositories automatically
==============================================

Description
-----------

Update your git repositories automatically when `remote` is set

# Install (for development)

- Clone repository: `git clone https://github.com/ochorocho/gitlab-mirror-pull.git`
- Run bundler: `bundle install`
- Copy and modify `config.example.yml` to `config.yml`

## Run

```bash
./bin/gitlab-mirror-pull -c config.example.yml -l INFO
```

# Using 'gem install'

### Install

```bash
gem install gitlab-mirror-pull
```

### Run

```bash
gitlab-mirror-pull -c /path/to/config.yml
```

Default config location

```bash
/etc/gitlab-mirror-pull/config.yml
```

## Setup a CronJob

If you want to trigger periodically 

```bash
* */1 * * *     git /usr/bin/ruby /usr/local/bin/gitlab-mirror-pull
```

## Setup gitlab webhook

Allow webhooks on `localhost` in gitlab (Admin -> Settings -> Outbound requests) 
and check `Allow requests to the local network from hooks and services` and hit save 

Go to your porject -> Settings -> Integrations:

* Add URL `http://localhost:8088/commit`
* Leave Token empty
* Check `Enable SSL verification` 
* Tick boxes to enable `Triggers` 