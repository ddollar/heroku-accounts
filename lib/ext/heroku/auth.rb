module Heroku
  class Auth

    def self.user
      fetch_from_account[:username]
    end

    def self.password
      fetch_from_account[:password]
    end

  private ####################################################################

    def self.extract_account
      @account ||= begin
        account = Heroku::Command.current_options[:account]

        unless account
          account = ENV["HEROKU_ACCOUNT"] || %x{ git config heroku.account }.chomp
        end

        raise(CommandFailed, <<-ERROR) if account.to_s.strip == ''
No account specified.

Run this command with --account <account name>

You can also add it as a git config attribute with:
  git config heroku.account work
        ERROR
        account
      end
    end

    def self.fetch_from_account
      account = Heroku::Command::Accounts.account(extract_account)
    end

  end
end
