require "heroku/command/base"

class Heroku::Command::Base

  def git_remotes(base_dir=Dir.pwd)
    remotes = {}

    return unless File.exists?(".git")
    
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
