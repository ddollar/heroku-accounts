# Heroku Accounts

## Installation

    $ heroku plugins:install git://github.com/ddollar/heroku-accounts.git

## Usage

To add accounts:

    $ heroku accounts:add personal
    Enter your Heroku credentials.
    Email: david@heroku.com
    Password: ******

    Add the following to your ~/.ssh/config

    Host heroku.personal
      Hostname heroku.com
      IdentityFile /PATH/TO/PRIVATE/KEY
      IdentitiesOnly yes

To switch an app to a different account:

    # in project root
    heroku accounts:set personal

To list accounts:

    $ heroku accounts
    personal
    work

To remove an account:

    $ heroku accounts:remove personal
    Account removed: personal
