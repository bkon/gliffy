class Gliffy::CLI::Task::User::List < Gliffy::CLI::Task
  def initialize(global_options, options, args)
    super global_options
  end

  def run
    account.users.each do |u|
      stdout.puts "%20s %40s" % [u.username, u.email]
    end
  end
end
