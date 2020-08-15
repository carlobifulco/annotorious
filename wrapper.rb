#!/usr/bin/env ruby
require './config'
require 'optparse'
require 'colored'
require 'shellwords'
require 'dotenv'
Dotenv.load




NAME="pdx_slide_server"
DOCKER_USER="carlobifulco"


def execute_command command_string
  puts "=> .#{command_string}".red
  puts `#{command_string}`.yellow
end


def docker_command_squeeze command
  command.squeeze(" ").gsub("\n","")
end



module Wrapper

  #command line entry point
  ############################
  def self.wrap params
    puts "getting params:#{params}".yellow
    puts "-i {INPUT WSI FILE}, -o {OUTPUT DIRECTORY}"
    if (params["i"]!= nil and params["o"]!=nil)
      path_file_input=Shellwords.escape(params["i"])
      path_file_output=Shellwords.escape(params["o"])
      `python3.6 openslide_extractor.py #{path_file_input} #{path_file_output}`
    else
      puts "wtf: missing parameters".red
      puts params.to_s.red
    end
  end

  def self.gem_to_docker
    execute_command "cp -p Gemfile ./lib_docker" if File.exists? "Gemfile"
    execute_command "cp -p Gemfile.lock  ./lib_docker" if File.exists? "Gemfile.lock"
  end

  def self.git comment=""
    command="git commit -am '#{comment} #{Time.now.to_s}'"
    execute_command command
    command="git push"
    execute_command command
  end
  ### make, bash, test
  ####################
  def self.build comment=""
    git comment
    gem_to_docker

    command= "docker build \
                      --build-arg CACHEBUST=$(date +%s)\
                      --build-arg GITHUB_TOKEN=#{ENV['GITHUB_TOKEN']}\
                      --tag #{DOCKER_USER}/#{NAME} \
                      lib_docker "
    execute_command  command
  end


  ### server install


  def self.hub
    puts "uploading to docker hub".yellow_on_green
    execute_command "docker login -p bifulcocarlo -u carlobifulco"
    execute_command "docker push #{DOCKER_USER}/#{NAME}"
  end




  ### login into container
  ##########################
  def self.test_bash mount_path="/Users/carlobifulco/Desktop"
    working_dir=File.dirname(File.absolute_path(mount_path))
    execute_command "docker stop #{DOCKER_USER}/#{NAME}"
    execute_command "docker rm #{DOCKER_USER}/#{NAME}"
    command= "docker  run -it -p 7563:7563 -v /data:/data -v #{File.dirname(__FILE__)}/public:/root/slide_server/public --entrypoint='bash' #{DOCKER_USER}/#{NAME}"
    puts command.yellow
    system command
  end





  ### login into container
  ##########################
  def self.test_container mount_path_target="/Users/carlobifulco/code_github/#{NAME}/test/1_ndpi_image.tif"
    #self.build
    execute_command "docker stop #{DOCKER_USER}/#{NAME}"
    execute_command "docker rm #{DOCKER_USER}/#{NAME}"
    command= "docker  run -it -p 7563:7563 -v /data:/data -v #{File.dirname(__FILE__)}/public:/root/slide_server/public #{DOCKER_USER}/#{NAME}"
    command=docker_command_squeeze command
    puts command.yellow
    return `#{command}`
  end




end

### input file and output file
params= ARGV.getopts("i:","o:")
puts params



if __FILE__ == $0
  $stdout.write Wrapper.wrap(params)
end
