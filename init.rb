require "fileutils"
require "heroku/command/accounts"
require "heroku/command/auth"

Heroku::Command::Help.group("Accounts") do |group|
  group.command "accounts",               "list accounts"
  group.command "accounts:add <name>",    "add an account"
  group.command "accounts.remove <name>", "remove an account"
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

  # def git_remotes(base_dir)
  #   remotes_matching(base_dir) do |name, url|
  #     case url
  #       when /git@#{heroku.host}:([\w\d-]+)\.git/  then $1
  #       when /git@heroku.[\w\d-]+:([\w\d-]+)\.git/ then $1
  #       else false
  #     end
  #   end
  # end
  # 
  # def remotes_matching(base_dir, &block)
  #   remotes = {}
  # 
  #   FileUtils.chdir(base_dir) do
  #     remote_names = %x{ git remote }.split("\n").map { |r| r.strip }
  #     remote_names.each do |name|
  #       remote_url = %x{ git config remote.#{name}.url }
  #       match = yield(name, remote_url)
  #       remotes[name] = match if match
  #     end
  #   end
  # 
  #   remotes
  # end
end
