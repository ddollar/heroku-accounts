require 'heroku/command/accounts'
require 'heroku/command/auth'

Heroku::Command::Help.group('Test Group') do |group|
  group.command('Test', 'Bar')
end
