require "heroku/command/base"
require "fileutils"
require "yaml"

# manage multiple heroku accounts
#
class Heroku::Command::Accounts < Heroku::Command::Base

  # accounts
  #
  # list all known accounts
  #
  def index
    display "No accounts found." if account_names.empty?

    current_account = Heroku::Auth.extract_account rescue nil

    account_names.each do |name|
      if name == current_account
        display "* #{name}"
      else
        display name
      end
    end
  end

  # accounts:add
  #
  # add an account to the local credential store
  #
  # -a, --auto  # automatically generate an ssh key and add it to .ssh/config
  #
  def add
        
    Heroku::Command.current_options[:account] = name = args.shift

    error("Please specify an account name.") unless name
    error("That account already exists.") if account_exists?(name)

    begin
      username, password = auth.ask_for_credentials
    rescue Heroku::API::Errors::NotFound
      error('Authentication failed.')
    end

    write_account(name,
      :username      => username,
      :password      => password
    )

    if options[:auto] then
      display "Generating new SSH key"
      system %{ ssh-keygen -t rsa -f "#{account_ssh_key(name)}" -N "" }

      display "Adding entry to ~/.ssh/config"
      File.open(File.expand_path("~/.ssh/config"), "a") do |file|
        file.puts
        file.puts "Host heroku.#{name}"
        file.puts "  HostName heroku.com"
        file.puts "  IdentityFile \"#{account_ssh_key(name)}\""
        file.puts "  IdentitiesOnly yes"
      end

      display "Adding public key to Heroku account: #{username}"
      Heroku::Auth.credentials = [username, password]
      Heroku::Auth.api.post_key(File.read(File.expand_path(account_ssh_key(name) + ".pub")))
    else
      display ""
      display "Add the following to your ~/.ssh/config"
      display ""
      display "Host heroku.#{name}"
      display "  HostName heroku.com"
      display "  IdentityFile /PATH/TO/PRIVATE/KEY"
      display "  IdentitiesOnly yes"
    end
    
  end

  # accounts:remove
  #
  # remove an account from the local credential store
  #
  def remove
    Heroku::Command.current_options[:account] = name = args.shift

    error("Please specify an account name.") unless name
    error("That account does not exist.") unless account_exists?(name)
    error("That account is the current account, set another account first.") if (current_account = Heroku::Auth.extract_account rescue nil) == name

    FileUtils.rm_f(account_file(name))

    # if the removed account is default, unset default
    if %x{ git config --global heroku.account }.chomp == name
      %x{ git config --global --unset heroku.account }
    end

    display "Account removed: #{name}"
  end

  # accounts:set
  #
  # set the default account of an app
  #
  def set
    Heroku::Command.current_options[:account] = name = args.shift

    error("Please specify an account name.") unless name
    error("That account does not exist.") unless account_exists?(name)

    %x{ git config heroku.account #{name} }

    git_remotes(Dir.pwd).each do |remote, app|
      %x{ git config remote.#{remote}.url git@heroku.#{name}:#{app}.git }
    end
  end

  # accounts:default
  #
  # set a system-wide default account
  #
  def default
    Heroku::Command.current_options[:account] = name = args.shift

    error("Please specify an account name.") unless name
    error("That account does not exist.") unless account_exists?(name)

    %x{ git config --global heroku.account #{name} }
  end

## account interface #########################################################

  def self.account(name)
    accounts = Heroku::Command::Accounts.new(nil)
    accounts.send(:account, name)
  end

private ######################################################################

  def account(name)
    error("No such account: #{name}") unless account_exists?(name)
    read_account(name)
  end

  def accounts_directory
    @accounts_directory ||= begin
      directory = File.join(home_directory, ".heroku", "accounts")
      FileUtils::mkdir_p(directory, :mode => 0700)
      directory
    end
  end

  def account_file(name)
    File.join(accounts_directory, name)
  end

  def account_names
    Dir[File.join(accounts_directory, "*")].map { |d| File.basename(d) }
  end

  def account_exists?(name)
    account_names.include?(name)
  end

  def account_ssh_key(name)
    File.expand_path("~/.ssh/identity.heroku.#{name}")
  end

  def auth
    if Heroku::VERSION < "2.0"
      Heroku::Command::Auth.new("")
    else
      Heroku::Auth
    end
  end

  def read_account(name)
    YAML::load_file(account_file(name))
  end

  def write_account(name, account)
    File.open(account_file(name), "w", 0600) { |f| f.puts YAML::dump(account) }
  end

  def error(message)
    puts message
    exit 1
  end

end
