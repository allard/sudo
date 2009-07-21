module Sudo
  require 'tempfile'

  def Sudo.install(sourcefile, destinationfile, options = {})
    case Rails.env
    when "production"
      user  = options[:user]  || "root"
      group = options[:group] || "wheel"
      mode  = options[:mode]  || 644
      %x{sudo install -o #{user} -g #{group} -m #{mode} #{sourcefile} #{destinationfile}}
    else
      mode  = options[:mode]  || 644
      %x{install -m #{mode} #{Rails.root}/tmp/filesystem/#{Rails.env}/#{sourcefile} #{Rails.root}/tmp/filesystem/#{Rails.env}/#{destinationfile}}
    end
  end

  def Sudo.tempfile(data)
    datafile = Tempfile.new("_temp")
    datafile.puts data
    datafile.close
    datafile.path
  end

  def Sudo.write(data, destination, options = {})
    f = Tempfile.new("_write")
    f.puts data
    f.close

    case Rails.env
    when "production"
      user  = options[:user]  || "root"
      group = options[:group] || "wheel"
      mode  = options[:mode]  || 644
      %x{sudo install -o #{user} -g #{group} -m #{mode} #{f.path} #{destination}}
    when "development", "test"
      mode  = options[:mode]  || 644
      %x{install -m #{mode} #{f.path} #{Rails.root}/tmp/filesystem/#{Rails.env}/#{destination}}
    end
  end

  def Sudo.exec(command, options = {})
    case Rails.env
    when "production"
      user = options[:user] || "root"
      %x{sudo -u #{user} #{command}}
    when "development"
      %x{#{command}}
    when "test"
      "sudo #{command}"
    end
  end

  def Sudo.read(filename)
    case Rails.env
    when "production"
      %x{sudo cat #{filename}}.strip
    else
      %x{cat #{Rails.root}/tmp/filesystem/#{Rails.env}/#{filename}}.strip
    end
  end

  def Sudo.initialize_test
    if %x{which rsync; echo $?}.to_i.zero?
      %x{rsync -a --delete #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/filesystem/test/}
    else
      %x{
        rm -rf #{Rails.root}/tmp/filesystem/test
        cp -rp #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/filesystem/test/
      }
    end
  end

  def Sudo.init_dev_from_test
    # Rsync is way faster and we prefer to use that if available
    if %x{which rsync; echo $?}.to_i.zero?
      %x{rsync -a --delete #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/filesystem/development/}
    else
      %x{
        rm -rf #{Rails.root}/tmp/filesystem/test
        cp -rp #{Rails.root}/test/fixtures/filesystem/ #{Rails.root}/tmp/filesystem/development/
      }
    end
  end

end
