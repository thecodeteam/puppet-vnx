# Copyright (C) 2014, EMC, Inc.

require 'fileutils'
require 'tmpdir'

#if IO.respond_to?(:popen4)
#  def open4(*args)
#    op4 = IO.popen4(*args)
#    return op4 unless block_given?
#    yield op4
#  end
#else
#  require 'open4'
#end
#require 'open3'
require 'shellwords'

module PuppetX
  module Puppetlabs
    module Transport
      module EMCVNX

        class Vnx

          #DEFAULT_ADMIN_SCOPE = 0
          #DEFAULT_CLI_PATH = '/opt/Navisphere/bin/naviseccli'

          attr_accessor :navicli
          attr_reader :array, :username, :password, :scope, :cli_path

          def initialize(option)
            @array    = option[:array]
            @username = option[:username]
            @password = option[:password]
            @host_addr = option[:host_addr]
            @scope    = option[:scope] #|| DEFAULT_ADMIN_SCOPE
            @cli_path = option[:cli_path] #|| DEFAULT_CLI_PATH
            Puppet.debug("#{self.class} initializing connection to: #{@array}")
          end

          def connect
            @navicli = setup_auth_file
            return
          end

          def secure_dir
            @secure_dir ||= Dir.mktmpdir("navicli-sec-", "/var/tmp")
          end

          def close
            FileUtils.remove_entry secure_dir
          end

          def setup_auth_file
            args = %W[-AddUserSecurity -password #{@password} -scope #{@scope} -user #{@username}]
            begin
              run(args, raise_on_failure=false)
            rescue
              # if this command fails, cleanup
              close
            raise
            end
          end

          def run(args, raise_on_failure=true)
            args = [ '-secfilepath', secure_dir, '-address', @host_addr] + args
            # err = out = nil
            #pid, stdin, stdout, stderr = open4(@cli_path, *args)
            # Open3.popen3(@cli_path, *args) do |stdin, stdout, stderr, t|
            #   out = stdout.read
            #   err = stderr.read
            # end
            output = `#{@cli_path} #{Shellwords.join args}`
            raise "Command error, output:\n#{output}" if raise_on_failure && !$?.success?
            output
          end

        end

        @vnxcli = nil

        def initial_cli()
          #Define VNX Login Info
          res = resource.catalog.resource(resource[:transport].to_s)
          if !res
            raise "Can't find transport"
          end
          option = {}
          option[:username] = res.provider.send(:username)
          option[:password] = res.provider.send(:password)
          option[:host_addr] = res.provider.send(:server)
          option[:array] = res.provider.send(:name)
          option[:scope] = res.provider.send(:scope)
          option[:cli_path] = res.provider.send(:cli_path)

          @vnxcli = Vnx.new(option)
          @vnxcli.connect
        end

        def run(args)
          if args.any? &:nil?
            raise ArgumentError, "Some arguments missing!. Arguments: #{args.inspect}."
          end

          args = args.map &:to_s #convert symbol, numbers to string

          if !@vnxcli
            initial_cli
          end
          debug "Run command: #{Shellwords.join args}"
          out = @vnxcli.run(args)
          debug out
          out
        end

        def self.included base
          base.send :extend, ClassMethods
        end


        def current_properties
          if @property_hash.empty?
            begin
              @property_hash = get_current_properties
            rescue
              @property_hash = {:ensure => :absent}
            end
          end
          @property_hash
        end

        module ClassMethods
          def mk_resource_property_methods
            [resource_type.validproperties, resource_type.parameters].flatten.each do |attr|
              attr = attr.intern
              next if attr == :name
              define_method(attr) do
                if current_properties[attr].nil?
                  :absent
                else
                  current_properties[attr]
                end
              end

              define_method(attr.to_s + "=") do |val|
                @property_flush[attr] = val
              end
            end
          end
        end
      end
    end
  end
end