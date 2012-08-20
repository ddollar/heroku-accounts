require "fileutils"
require "accounts/heroku/auth"
require "accounts/heroku/command/accounts"
require "accounts/heroku/command/auth"
require "accounts/heroku/command/base"

Heroku::Command.global_option :account, "--account ACCOUNT"
