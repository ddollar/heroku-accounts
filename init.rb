require "fileutils"
require "ext/heroku/auth"
require "ext/heroku/command/accounts"
require "ext/heroku/command/auth"

Heroku::Command::Help.group("Accounts") do |group|
  group.command "accounts",                "list accounts"
  group.command "accounts:add <name>",     "add an account"
  group.command "accounts:remove <name>",  "remove an account"
  group.command "accounts:set <name>",     "use in an app directory to set the account for that app"
  group.command "accounts:default <name>", "set an account as system-wide default"
end

class Heroku::Command::Base

  def git_remotes(base_dir)
    remotes = {}

    FileUtils.chdir(base_dir) do
      remote_names = %x{ git remote }.split("\n").map { |r| r.strip }
      remote_names.each do |name|
        case %x{ git config remote.#{name}.url }
          when /git@#{heroku.host}:([\w\d-]+)\.git/  then remotes[name] = $1
          when /git@heroku.[\w\d-]+:([\w\d-]+)\.git/ then remotes[name] = $1
        end
      end
    end

    remotes
  end

end

if Heroku::Command.respond_to?(:global_option)
  Heroku::Command.global_option :account, "--account ACCOUNT"
end
