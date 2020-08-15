# -*- encoding : utf-8 -*-
require "colored"
require "config"
require_relative "../lib_util/util"

#MONGO_DATA_ROOT="/Users/carlobifulco/data/db/mongo_dbs"

#
# spawn "docker run -v /data/db --name  #{APP_NAME}-data busybox true"

### closes and reboots all supporting containers

### full code changes pushed into docker

module DockerManager
  APP_NAME=File.basename File.absolute_path "."
  DATABASE_CONTAINER_NAME="database"
  VOLUME_CONTAINER_NAME="volume"
  MONGO_DATA_ROOT=CONFIG["MONGO_DATA_ROOT"]
  SINATRA_PORT=CONFIG["SINATRA_PORT"]
  APP_DATABASE_DIRECTORY=MONGO_DATA_ROOT+"/"+APP_NAME
  DOCKER_SAVE_PATH=CONFIG["DOCKER_SAVE_PATH"]+"/"+APP_NAME

  module_function

  # def app_container_connect
  #   command= "docker exec -it #{APP_NAME}-container bash"
  #   puts command.red
  #   system "docker exec -it #{APP_NAME}-container bash"
  # end
  #

  #

  ### HUB
  #########


  def hub container
    puts "uploading to docker hub".yellow_on_green
    execute_command "docker login -p #{ENV['DOCKERHUB_PASSWORD']} -u #{ENV['DOCKERHUB_USER']}"
    execute_command "docker push  #{ENV['DOCKERHUB_USER']}/#{container}"
  end

  def hub_app
    hub "#{APP_NAME}-image"
  end


  def hub_database
    hub "#{APP_NAME}-#{DATABASE_CONTAINER_NAME}"
  end

  def hub_all
    hub_app
    hub_volume
    hub_database
  end
# def hub_volume
#   hub "#{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
# end
#
#
# def hub_database
#   hub "#{APP_NAME}-#{DATABASE_CONTAINER_NAME}"
# end
#
# def hub_all
#   hub_app
#   hub_volume
#   hub_database
# end

### BUILDING
#########

  # def app_container_build_restart_full_development
  #   app_container_build_restart_full(docker_path: "./lib_docker/docker_app/", environment: "development")
  # end

  def app_container_build_restart_full_cbb_api (branch: "cbb_api")
    app_container_build_restart_full(docker_path: "./lib_docker/docker_app/", branch: branch)
  end




  # def app_container_build_restart_full_cbb
  #   app_container_build_restart_full(docker_path: "./lib_docker/docker_app/", environment: "development",checkout: "cbb_develop")
  # end

  def git_checkout branch
    if branch==false
      return "true"
    else
      return "git checkout -b branch origin/#{branch}"
    end
  end

  def database_container_restart docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
    puts "START WORKING ON DATABASE IMAGES AND CONTAINER".yellow_on_green
    execute_command "docker stop #{APP_NAME}-#{container_name}"
    execute_command "docker rm  #{APP_NAME}-#{container_name}"
    execute_command "docker build  --tag carlobifulco/#{APP_NAME}-#{container_name}  #{docker_path}"
    # execute_command "docker run -d --volumes-from  #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
    #                   --name  #{APP_NAME}-#{container_name} #{APP_NAME}-#{container_name} \
    #                   mongod  --smallfiles "
    execute_command "docker run \
                     -d \
                     --name #{APP_NAME}-#{container_name} \
                     carlobifulco/#{APP_NAME}-#{container_name} \
                     mongod --smallfiles "
    Thread.new do
      sleep 3
      execute_command "docker top  #{APP_NAME}-#{container_name}"
    end
    puts "DONE WITH DATABASE".yellow_on_green
  end



  def app_container_build_restart_full(docker_path: './lib_docker/docker_app/', environment: 'development', branch: "master")
    ## docker pull carlobifulco/sendout-monitor
    puts "START WORKING ON APP IMAGES AND CONTAINER".yellow_on_green
    #composer_down
    # volume_container_restart
    # database_container_restart
    gem_to_docker
    database_container_restart
    execute_command "docker build\
                      --build-arg CACHEBUST=$(date +%s)\
                      --build-arg GITHUB_TOKEN=#{ENV['GITHUB_TOKEN']}\
                      --tag carlobifulco/#{APP_NAME}-image #{docker_path}".squeeze(" ").gsub("\n","")
    execute_command "docker stop #{APP_NAME}-container"
    execute_command "docker rm -v #{APP_NAME}-container"
    execute_command_io  "docker run\
                        -d\
                        -v  /var/run/docker.sock:/var/run/docker.sock\
                        -v syapse_python_bin:/syapse_python_bin
                        -v syapse_db_store:/data/db/mongodbs/syapse
                        -p #{SINATRA_PORT}:#{SINATRA_PORT}\
                        --name #{APP_NAME}-container\
                        --link #{APP_NAME}-#{DATABASE_CONTAINER_NAME}:db\
                        carlobifulco/#{APP_NAME}-image \
                        sh -c '
                        #{git_checkout(branch)} &&\
                        cp ./bin/*.py /syapse_python_bin &&\
                        /usr/local/bin/ruby /root/syapse/server.rb
                        -p #{SINATRA_PORT}'"\
                        .squeeze(" ").gsub("\n","")
    Thread.new do
      sleep 3
      execute_command("docker top #{APP_NAME}-container")
    end
    puts "\n"
    puts "if testing".yellow_on_green
    puts " DockerManager.app_container_images_save if needed".yellow
    puts " DockerManager.app_container_local_web if needed".yellow
  end

  # def app_container_restart_full(docker_path: './lib_docker/docker_app/', environment: 'development', checkout: false)
  #   ## docker pull carlobifulco/sendout-monitor
  #   puts "START WORKING ON APP IMAGES AND CONTAINER".yellow_on_green
  #   #composer_down
  #   volume_container_restart
  #   database_container_restart
  #   gem_to_docker
  #   execute_command "docker stop #{APP_NAME}-container"
  #   execute_command "docker rm -v #{APP_NAME}-container"
  #   execute_command_io "docker run\
  #                       -d\
  #                       -v  /var/run/docker.sock:/var/run/docker.sock\
  #                       -p #{SINATRA_PORT}:#{SINATRA_PORT}\
  #                       --volumes-from  #{APP_NAME}-#{VOLUME_CONTAINER_NAME}\
  #                       --name #{APP_NAME}-container\
  #                       --link #{APP_NAME}-#{DATABASE_CONTAINER_NAME}:db\
  #                       carlobifulco/#{APP_NAME}-image \
  #                       sh -c '
  #                       #{git_checkout(environment, checkout)} &&\
  #                       /usr/local/bin/ruby /root/#{APP_NAME}/server.rb
  #                       -p #{SINATRA_PORT}
  #                       -e #{environment}'"
  #   Thread.new do
  #     sleep 3
  #     execute_command "docker top #{APP_NAME}-container"
  #   end
  #   puts "\n"
  #   puts "if testing".yellow_on_green
  #   puts " DockerManager.app_container_images_save if needed".yellow
  #   puts " DockerManager.app_container_local_web if needed".yellow
  #   puts ".curl -u molpath:molpath -F file_dump=@./test/phi.phi http://192.168.59.103:8345/api_post_phi_tsv_file".yellow
  #   puts ("*" *80).yellow_on_green
  #   puts "DONE WITH APP".yellow_on_green
  # end




  def app_container_images_save
    images_save
  end

  def app_container_local_web
    Thread.new do
      execute_command "open http://localhost:#{SINATRA_PORT}" if Util.testing?
    end
  end

  # def app_container_mounts
  #   puts `docker inspect #{APP_NAME}-container | jq '.[0].Mounts' `
  # end



  #
  # def app_container_restart_light
  #   execute_command "docker stop #{APP_NAME}-container"
  #   execute_command "docker rm -v #{APP_NAME}-container"
  #   execute_command "docker run \
  #                       -d\
  #                       -v  /var/run/docker.sock:/var/run/docker.sock\
  #                       -p #{SINATRA_PORT}:#{SINATRA_PORT}\
  #                       --volumes-from  #{APP_NAME}-#{VOLUME_CONTAINER_NAME}\
  #                       --name #{APP_NAME}-container\
  #                       --link #{APP_NAME}-#{DATABASE_CONTAINER_NAME}:db\
  #                       --link carlobifulco/pdx_hotspots-container:pdx_reviewer \
  #                       carlobifulco/#{APP_NAME}-image \
  #                       /usr/local/bin/ruby /root/#{APP_NAME}/server.rb \
  #                       -p #{SINATRA_PORT} -e #{environment}"
  #   puts `docker ps -a | grep nant_anno`.green
  #   sleep 3
  #   puts `docker ps -a | grep nant_anno`.green
  #   Thread.new do
  #     sleep 3
  #     execute_command "docker top #{APP_NAME}-container"
  #     app_container_local_web
  #   end
  # end

  #
  #
  # def app_container_bash (environment: 'development', checkout: false)
  #   execute_command "docker stop #{APP_NAME}-container"
  #   execute_command "docker rm -v #{APP_NAME}-container"
  #   system "docker run \
  #           -it \
  #           -v  /var/run/docker.sock:/var/run/docker.sock\
  #           -p #{SINATRA_PORT}:#{SINATRA_PORT}\
  #           --volumes-from  #{APP_NAME}-#{VOLUME_CONTAINER_NAME}\
  #           --name #{APP_NAME}-container\
  #           --link #{APP_NAME}-#{DATABASE_CONTAINER_NAME}:db\
  #           carlobifulco/#{APP_NAME}-image \
  #           sh -c '
  #           #{git_checkout(environment, checkout)} &&\
  #           bash'"
  # end
  #
  # def app_container_attach
  #   execute_command "docker stop #{APP_NAME}-container"
  #   execute_command "docker rm -v #{APP_NAME}-container"
  #   execute_command "docker run \
  #                    -d \
  #                    -p #{SINATRA_PORT}:#{SINATRA_PORT} \
  #                    --volumes-from #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #                    --name #{APP_NAME}-container \
  #                    --link #{APP_NAME}-#{DATABASE_CONTAINER_NAME}:db \
  #                    #{APP_NAME}-image \
  #                    /usr/local/bin/ruby /root/#{APP_NAME}/server.rb -p #{SINATRA_PORT}"
  #   execute_command "docker attach #{APP_NAME}-container"
  # end
  #
  # def app_container_inspect
  #   app_container_restart_light
  #   Thread.new do
  #     sleep 3
  #     execute_command "docker top #{APP_NAME}-container"
  #     execute_command "open http://`boot2docker ip`:#{SINATRA_PORT}"  if Util.testing?
  #   end
  #   system "docker exec -it #{APP_NAME}-container pry"
  # end

  # ### DATABASE
  # ####################
  #
  # def database_container_restart docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
  #   mongo_conf
  #   puts "START WORKING ON DATABASE IMAGES AND CONTAINER".yellow_on_green
  #   execute_command "docker stop #{APP_NAME}-#{container_name}"
  #   execute_command "docker rm  #{APP_NAME}-#{container_name}"
  #   execute_command "docker build  --tag carlobifulco/#{APP_NAME}-#{container_name}  #{docker_path}"
  #   # execute_command "docker run -d --volumes-from  #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #   #                   --name  #{APP_NAME}-#{container_name} #{APP_NAME}-#{container_name} \
  #   #                   mongod  --smallfiles "
  #   execute_command "docker run \
  #                    -d \
  #                    --volumes-from #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #                    --name #{APP_NAME}-#{container_name} \
  #                    carlobifulco/#{APP_NAME}-#{container_name} \
  #                    mongod --smallfiles "
  #   Thread.new do
  #     sleep 3
  #     execute_command "docker top  #{APP_NAME}-#{container_name}"
  #   end
  #   puts "DONE WITH DATABASE".yellow_on_green
  # end
  #
  # def database_container_bash docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
  #   system "docker run -it  \
  #           --volumes-from #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #           #{APP_NAME}-#{container_name} \
  #           bash"
  # end
  #
  # def database_container_bash_connect docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
  #   command= "docker exec -it #{APP_NAME}-#{container_name} bash"
  #   puts command.red
  #   system "docker exec -it #{APP_NAME}-#{container_name} bash"
  # end
  #
  # def database_container_mongoexec docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
  #   system "docker exec \
  #           -it #{APP_NAME}-#{container_name} \
  #           mongo"
  # end
  #
  # def database_container_restart_light
  #   docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
  #   puts "START WORKING ON DATABASE IMAGES AND CONTAINER".yellow_on_green
  #   execute_command "docker stop #{APP_NAME}-#{container_name}"
  #   execute_command "docker rm  #{APP_NAME}-#{container_name}"
  #   execute_command "docker run \
  #                    -d \
  #                    --volumes-from #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #                    --name #{APP_NAME}-#{container_name} \
  #                    carlobifulco/#{APP_NAME}-#{container_name} \
  #                    mongod  --smallfiles --dbpath #{APP_DATABASE_DIRECTORY} "
  #   Thread.new do
  #     sleep 3
  #     execute_command "docker top #{APP_NAME}-#{container_name}"
  #   end
  #   puts "DONE WITH DATABASE".yellow_on_green
  # end
  #
  # ### VOLUME
  # ### ./lib_docker/docker_volume/backup.tar" is loaded by the volume docker file in /data/db
  # def volume_container_restart docker_path="./lib_docker/docker_volume/"
  #   if Util.linux?
  #       mount_command="#{MONGO_DATA_ROOT}/#{APP_NAME}:/data/db"
  #   else
  #       mount_command="/Users/carlobifulco/mongo_test/pdx_reporter:/data/db"
  #   end
  #   FileUtils.mkdir_p(mount_command.split(":").first) unless Dir.exists? mount_command.split(":").first
  #   puts "START WORKING ON VOLUME IMAGES AND CONTAINER".yellow_on_green
  #   execute_command "docker stop #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   execute_command "docker rm -v #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   execute_command "docker build  --tag carlobifulco/#{APP_NAME}-#{VOLUME_CONTAINER_NAME} #{docker_path}"
  #   execute_command "docker run \
  #                    -v #{mount_command} \
  #                    --name #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #                    carlobifulco/#{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   puts "DONE WITH VOLUME".yellow_on_green
  #   #execute_command "docker run -v /data/db  --name  #{APP_NAME}-#{VOLUME_CONTAINER_NAME} #{APP_NAME}-volume"
  # end
  #
  # def volume_container_restart_light docker_path="./lib_docker/docker_volume/"
  #   if Util.linux?
  #       mount_command="#{MONGO_DATA_ROOT}/#{APP_NAME}:/data/db"
  #   else
  #       mount_command="/Users/carlobifulco/mongo_test/pdx_reporter:/data/db"
  #   end
  #   puts "START WORKING ON VOLUME IMAGES AND CONTAINER".yellow_on_green
  #   execute_command "docker stop #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   execute_command "docker rm -v #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   persistance_data_directory="#{MONGO_DATA_ROOT}/#{APP_NAME}"
  #   volume_persistence_data_directory_command="bash -c \"mkdir -p #{persistance_data_directory}\""
  #   execute_command "docker run \
  #                   -v #{mount_command}  \
  #                    #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #                    carlobifulco/#{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #                    #{volume_persistence_data_directory_command}"
  #   puts "DONE WITH VOLUME".yellow_on_green
  # end
  #
  #
  # ### XXX deprecated...
  # ### back up of the app's docker volume /data/db directroy into local docker_volume directory
  # # backup is then used by the dockerfile of the volume upon the container restart process
  # # this method is applied only in a testing environment
  # # def volume_container_backup
  # #   execute_command "docker run  --rm --volumes-from #{APP_NAME}-#{VOLUME_CONTAINER_NAME} -v `pwd`/lib_docker/docker_volume:/volume_backup ubuntu tar cvf /volume_backup/backup.tar /data/db/#{APP_NAME}" if Util.testing?
  # # end
  #
  # def volume_container_failure_inspect docker_path="./lib_docker/docker_database/", container_name=DATABASE_CONTAINER_NAME
  #   system "docker start -i #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  # end
  #
  # ### mounts /data/db on the local file system; not working on os X but only on unix....
  # def volume_container_bash docker_path="./lib_docker/docker_database/"
  #   execute_command "docker stop #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   execute_command "docker rm -v #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  #   persistance_data_directory="#{MONGO_DATA_ROOT}/#{APP_NAME}"
  #   #execute_command "docker run -v /Users/carlobifulco/data/db/#{APP_NAME}:/data/db  --name  #{APP_NAME}-data #{APP_NAME}-volume "
  #   system "docker run \
  #           -it \
  #           -v #{persistance_data_directory}:/data/db
  #           --name #{APP_NAME}-#{VOLUME_CONTAINER_NAME} \
  #           #{APP_NAME}-volume \
  #           bash"
  # end
  #
  # def volume_container_inspect docker_path="./lib_docker/docker_database/"
  #
  #   #execute_command "docker run -v /Users/carlobifulco/data/db/#{APP_NAME}:/data/db  --name  #{APP_NAME}-data #{APP_NAME}-volume "
  #   system "docker inspect #{APP_NAME}-#{VOLUME_CONTAINER_NAME}"
  # end

  def execute_command command_string
    puts "=> .#{command_string}".red
    puts `#{command_string}`.squeeze(" ").yellow
  end

  def execute_command_io command_string
    IO.popen(command_string,'r') do |io|
      puts ".#{command_string} ==>".red
      while line=io.gets
        puts line.yellow
      end
    end
  end

  # def database_container_connect
  #   command=  "docker exec -it #{APP_NAME}-#{DATABASE_CONTAINER_NAME} bash"
  #   puts command.red
  #   system "docker exec -it #{APP_NAME}-#{DATABASE_CONTAINER_NAME} bash"
  # end

  ### Clean up of environment

  def containers_clean_all
    execute_command "docker stop `docker ps -a -q`"
    execute_command "docker rm $(docker ps -a -q)"
  end

  def containers_find
    regex=Regexp.new "#{APP_NAME}"
    `docker ps -a`.split("\n").grep(regex).map {|x| x.split()[-1]}
  end

  def containers_stop_app
    containers_find.each {|x| execute_command "docker stop #{x} && docker rm #{x}"}
  end

  def images_find
    regex=Regexp.new "#{APP_NAME}"
    `docker images`.split("\n").grep(regex).map {|x| x.split()[0]}
  end

  def images_clean_all
    containers_clean_all
    execute_command "docker rmi `docker images -q`"
  end

  def images_clean_app
    containers_stop_app
    images_find.each {|x| execute_command "docker rmi #{x}"}
  end

  def images_run
    images_load
    volume_container_restart_light
    database_container_restart_light
    app_container_restart_light
  end

  def images_save
    puts "Saving applications images to #{DOCKER_SAVE_PATH}".yellow_on_green
    execute_command "mkdir -p #{DOCKER_SAVE_PATH}" unless Dir.exists? DOCKER_SAVE_PATH
    images_find.each do |image_name|
      execute_command "docker save -o #{DOCKER_SAVE_PATH}/#{image_name}.tar #{image_name}"
    end
  end

  def images_load
    (Dir.glob "#{DOCKER_SAVE_PATH}/*.tar").each do |x|
      execute_command "docker load -i #{x}"
    end
  end

  def images_find
    regex=Regexp.new "#{APP_NAME}"
    `docker images`.split("\n").grep(regex).map {|x| x.split()[0]}
  end

  ### Monitor runnning processes
  def containers_top
    `docker ps -a | grep sendout`.split("\n").map{|x| x.split()[0]}.each do |c|

        puts `docker top #{c}`.green

    end
  end

  # def git_tar
  #   puts "GIT & TAR".yellow_on_green
  #   puts "committing current branch".yellow
  #   me=`whoami`
  #   changes= `git diff | grep @@`
  #   current_branch=`git rev-parse --abbrev-ref HEAD`
  #   execute_command "git commit -am \"#{Time.now}: automated deployment - #{me}\""
  #   puts "archiving current branch for image creation in docker app".yellow
  #   execute_command "git archive -o ./lib_docker/docker_app/latest.tar -v #{current_branch}"
  #   if `git diff` != ""
  #     execute_command "git commit \
  #                      -am \"squash! #{Time.now}: automated deployment; after tar creation - #{me}; changes=#{changes}\""
  #   end
  #   puts "DONE WITH GIT & TAR".yellow_on_green
  # end
  #
  # def mongo_conf
  #   x=File.read("./lib_docker/docker_database/mongod.conf")
  #   x.gsub! /\/data\/db.*/, "/data/db/#{APP_NAME}"
  #   File.write("./lib_docker/docker_database/mongod.conf", x)
  # end

  ### avoids docker unnecessarly re-pulling all gemfiles
  # instead they are taken from cache...
  def gem_to_docker
    `cp -p Gemfile ./lib_docker/docker_app`
    `cp -p Gemfile.lock  ./lib_docker/docker_app`
  end

end

if __FILE__ == $0
  include DockerManager
end
