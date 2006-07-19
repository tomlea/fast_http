
def sub_rant(name)
  return <<-END
desc "Behavior for #{name}"
task :all do
  sys "spec", sys["*.rb"]
end
END
end

def spec_file(context)
  return <<-END
require 'rfuzz/session'

context "#{context}" do
  setup do
  end

  specify "#{context} spec" do
  end
end
END
end

