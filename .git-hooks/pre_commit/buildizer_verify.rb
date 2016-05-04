module Overcommit::Hook::PreCommit
  class BuildizerVerify < Base
    def run
      require 'bundler/setup'
      require 'buildizer'

      ::Buildizer::Buildizer.new.verify
      :pass
    rescue ::Buildizer::Error => e
      $stderr.puts e.net_status.net_status_message
      :fail
    end
  end
end
