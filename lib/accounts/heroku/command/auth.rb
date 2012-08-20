module Heroku::Command
  class Auth

    def user
      fetch_from_account[:username]
    end

    def password
      fetch_from_account[:password]
    end

  private ####################################################################

    def extract_account
      @account ||= begin
        account = extract_option('--account')

        unless account
          account = ENV["HEROKU_ACCOUNT"] || %x{ git config heroku.account }.chomp
        end

        raise(Heroku::Command::CommandFailed, <<-ERROR) if account.to_s.strip == ''
No account specified.

Run this command with --account <account name>

You can also add it as a git config attribute with:
  git config heroku.account work
        ERROR
        account
      end
    end

    def fetch_from_account
      account = Heroku::Command::Accounts.account(extract_account)
    end

  end
end
