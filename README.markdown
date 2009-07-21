# Sudo Rails Plugin #

The sudo module makes it easier to deal with with system files for your rails project.

## Problem: ##

  - The Rails application should not run as root, and sometimes files needs to be installed as root
  - Everything in rails should be testable, including installing files

## Installation: ##

./script/plugin install git@github.com:allard/sudo.git

In production, sudo has to be configured to allow your web application user
to run. If the owner is www, you can add this to /etc/sudoers:

    www  ALL=(ALL) NOPASSWD: SETENV: ALL

## Example: ##

    class Post < ActiveRecord::Base
    
      def after_save
        # The following function will write to:
        #   in production:  /var/tmp/outfile
        #   in development: Rails.root/tmp/filesystem/development/var/tmp/outfile
        #   in test:        Rails.root/tmp/filesystem/test/var/tmp/outfile
        #
        # In Production, the file will be owned as root
        # In Development and Test, the file ownership won't change
        # The file mode will change in all environments
        #
        Sudo.write(data, "/var/tmp/outfile", :user => "root", :mode => 600)
      end
    
    end

    class PostTest < ActiveSupport::TestCase

      def setup
        # This will reset Rails.root/tmp/filesystem/test with
        # any files from Rails.root/test/fixtures/filesystem
        Sudo.initialize_test
      end

      def test_check_outfile
        # Sudo.read will read from
        #   in production:  /var/tmp/outfile
        #   in development: Rails.root/tmp/filesystem/development/var/tmp/outfile
        #   in test:        Rails.root/tmp/filesystem/test/var/tmp/outfile
        #
        Post.create!(:data => "some_data")
        assert_equal "some_data", Sudo.read("/var/tmp/outfile")
      end

    end

## TODO: ##

  - There's plenty of more functions that could be implemented like ln, cp, rm, ...

