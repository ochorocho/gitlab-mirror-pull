Fetch/update gitlab repositories automatically
==============================================

Description
-----------

Update your git repositories automatically when `remote` is set

Install
-------

- Clone repository: `git clone https://github.com/ochorocho/gitlab-mirror-pull.git`
- Run bundler: `bundle install`
- Copy and modify `config.example.yml` to `config.yml`

Run
---

```ruby
ruby gitlab-mirror-pull.rb
```

Setup a CronJob
---------------

If you want to trigger periodically 

```bash
* */1 * * *     git /usr/bin/ruby /usr/local/bin/gitlab-mirror-pull
```

Using 'gem install'
-------------------

Install

```bash
gem install gitlab-mirror-pull
```

Run

```bash
gitlab-mirror-pull -c /path/to/config.yml
```

Default config location

```
/etc/gitlab-mirror-pull/config.yml
```

