FROM google/cloud-sdk:latest
RUN echo "o"
RUN apt-get update && apt-get upgrade -y --no-install-recommends
RUN apt-get install -yqq  libvips

RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean

# Install rbenv and ruby-build





RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/versions/2.7.0/bin:/root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
RUN rbenv  install 2.7.0
RUN rbenv global 2.7.0
RUN rbenv local 2.7.0

# Start server
ENV PORT 7563
EXPOSE 7563
RUN mkdir /server
COPY . /server
WORKDIR /server
RUN bundle install

CMD ["ruby", "/server/server.rb"]


# FROM debian:buster
# ARG CLOUD_SDK_VERSION=276.0.0
# ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
# ENV CLOUDSDK_PYTHON=python3
# ENV PATH "$PATH:/opt/google-cloud-sdk/bin/"
# RUN apt-get -qqy update && apt-get install -qqy \
#         curl \
#         gcc \
#         python3-dev \
#         python3-pip \
#         apt-transport-https \
#         lsb-release \
#         openssh-client \
#         git \
#         make \
#         gnupg && \
#     pip3 install -U crcmod && \
#     echo 'deb http://deb.debian.org/debian/ sid main' >> /etc/apt/sources.list && \
#     export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
#     echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
#     apt-get update && \
#     apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-python-extras=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-go=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-datalab=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-pubsub-emulator=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-bigtable-emulator=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-cbt=${CLOUD_SDK_VERSION}-0 \
#         kubectl && \
#     gcloud --version 
# VOLUME ["/root/.config", "/root/.kube"]





# FROM ruby:2.7.0

# RUN echo "a"
# RUN apt-get update && apt-get upgrade -y --no-install-recommends

#   git \
#   build-essential \
#   zlib1g-dev \
#   ncurses-dev \
#   g++ \
#   emacs24-nox \
#   locales \
#   locales-all\
#   ant \
#   default-jre \
#   libvips



# ### Locales issue on ruby docker image
# ########################################
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8


# # GCLOUD
# ARG CLOUD_SDK_VERSION=276.0.0
# ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
# ENV CLOUDSDK_PYTHON=python3
# ENV PATH "$PATH:/opt/google-cloud-sdk/bin/"
# RUN apt-get -qqy update && apt-get install -qqy \
#         curl \
#         gcc \
#         python3-dev \
#         python3-pip \
#         apt-transport-https \
#         lsb-release \
#         openssh-client \
#         git \
#         make \
#         gnupg && \
#     pip3 install -U crcmod && \
#     echo 'deb http://deb.debian.org/debian/ sid main' >> /etc/apt/sources.list && \
#     export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
#     echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
#     apt-get update && \
#     apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-python-extras=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-app-engine-go=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-datalab=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-pubsub-emulator=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-bigtable-emulator=${CLOUD_SDK_VERSION}-0 \
#         google-cloud-sdk-cbt=${CLOUD_SDK_VERSION}-0 \
#         kubectl 
# RUN    gcloud --version 
# # ENV CLOUD_SDK_VERSION 263.0.0
# # RUN apt-get -qqy update && apt-get install -qqy \
# #         curl \
# #         gcc \
# #         python-dev \
# #         python-setuptools \
# #         apt-transport-https \
# #         lsb-release \
# #         openssh-client \
# #         git \
# #     && easy_install -U pip && \
# #     pip install -U crcmod   && \
# #     export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
# #     echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
# #     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
# #     apt-get update && \
# #     apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-app-engine-go=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-datalab=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-pubsub-emulator=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-bigtable-emulator=${CLOUD_SDK_VERSION}-0 \
# #         google-cloud-sdk-cbt=${CLOUD_SDK_VERSION}-0 \
# #         kubectl && \
# #     gcloud config set core/disable_usage_reporting true && \
# #     gcloud config set component_manager/disable_update_check true


# WORKDIR /root
# ### RUBY
# ########

# RUN echo 'gem: --no-rdoc --no-ri' >> /root/.gemrc





# # Start server
# ENV PORT 7563
# EXPOSE 7563

# CMD ["ruby", "server.rb"]
