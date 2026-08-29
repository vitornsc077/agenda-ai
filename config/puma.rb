# This configuration file will be evaluated by Puma.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV") { "development" }

plugin :tmp_restart
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
