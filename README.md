gitlab-mirror-pull
==============================================
Gitlab-mirror-pull automatically fetches and updates GitLab repositories. 

Description
-----------

Update your git repositories automatically when `remote` is set

* Adds a command to fetch repositories
* Run a tiny Webserver to integrate with Gitlabs webhooks
* Adds init script to `/etc/init.d/gitlab-mirror-server`

# Install (for development)

* Clone repository: `git clone https://github.com/ochorocho/gitlab-mirror-pull.git`
* Run bundler: `bundle install`
* Copy and modify `config.example.yml` to `config.yml`

## Run

```bash
./bin/gitlab-mirror-pull -c config.yml -l INFO
```

# Using 'gem install'

### Install

```bash
gem install gitlab-mirror-pull
```

:warning: Make sure you run the script/server as `git` user. This is default for omnibus installation but may differ. In case you run the binary directly use this command `sudo -u git -H gitlab-mirror-pull`

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
* Run server `sudo /etc/init.d/gitlab-mirror-server start` 

**Logs**

* `/var/log/gitlab-mirror-server.err`
* `/var/log/gitlab-mirror-server.log`

# Run with docker

```bash
docker run -ti --rm -v "/absolute/path/to/repositories/":/repositories  -v "/absolute/path/to/config.docker.yml":/config.docker.yml ochorocho/gitlab-mirror-pull
```
