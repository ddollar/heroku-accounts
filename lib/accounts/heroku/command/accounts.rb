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
  def add
    name = args.shift

    error("Please specify an account name.") unless name
    error("That account already exists.") if account_exists?(name)

    begin
      username, password = auth.ask_for_credentials
    rescue Heroku::API::Errors::NotFound
      error('Authentication failed.')
    end

    write_account(name, :username => username, :password => password)
  end

  # accounts:remove
  #
  # remove an account from the local credential store
  #
  def remove
    name = args.shift

    error("Please specify an account name.") unless name
    error("That account does not exist.") unless account_exists?(name)
    error("That account is the current account, set another account first.") if current_account == name

    FileUtils.rm_f(account_file(name))

    display "Account removed: #{name}"
  end

  # accounts:set
  #
  # sets the current account
  #
  def set
    name = args.shift

    error("Please specify an account name.") unless name
    error("That account does not exist.") unless account_exists?(name)

    credentials = account(name)
    auth.credentials = [credentials[:username], credentials[:password]]
    auth.write_credentials
  end

  private

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

  def accounts
    account_names.map { |name| account(name).merge(:name => name) }
  end

  def account_exists?(name)
    account_names.include?(name)
  end

  def auth
    Heroku::Auth
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

  def current_account
    account = accounts.find { |a| a[:username] == auth.user }
    account[:name] if account
  end
end
