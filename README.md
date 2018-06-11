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
0 */1 * * *	/usr/bin/ruby /path/to/gitlab-mirror-pull.rb
```