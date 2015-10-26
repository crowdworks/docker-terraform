FROM  ubuntu
MAINTAINER Yusuke KUOKA <yusuke.kuoka@crowdworks.co.jp>

ENV DEBIAN_FRONTEND noninteractive

RUN locale -a
RUN locale-gen ja_JP.UTF-8
RUN locale-gen en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    autoconf \
    unzip \
    git \
    # for awscli
    python-pip \
    libxml2-dev \
    nodejs \
    npm

RUN curl -L https://github.com/github/hub/releases/download/v2.2.1/hub-linux-386-2.2.1.tar.gz | tar zxvf -
RUN cp hub-linux-386-2.2.1/hub /usr/local/bin/hub

RUN curl -L https://dl.bintray.com/mitchellh/terraform/terraform_0.6.6_linux_amd64.zip -O
RUN unzip terraform_0.6.6_linux_amd64.zip -d terraform-dir
RUN cp -R terraform-dir/* /usr/local/bin

RUN curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -P chefdk

RUN echo 'eval "$(chef shell-init bash)"' > /etc/profile.d/chefdk.sh
ENV PATH "/opt/chefdk/bin:/root/.chefdk/gem/ruby/2.1.0/bin:/opt/chefdk/embedded/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV GEM_ROOT "/opt/chefdk/embedded/lib/ruby/gems/2.1.0"
ENV GEM_HOME "/root/.chefdk/gem/ruby/2.1.0"
ENV GEM_PATH "/root/.chefdk/gem/ruby/2.1.0:/opt/chefdk/embedded/lib/ruby/gems/2.1.0"

RUN chef gem install specific_install
RUN chef gem specific_install -l https://github.com/crowdworks/kitchen-ec2.git -b fix-regression
RUN chef gem install \
    knife-ec2 \
    knife-zero \
    kitchen-vagrant \
    serverspec \
    rake \
    sshkit

RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq && \
    echo '{"test":"jq ran successfully."}' | jq .test

RUN pip install awscli
RUN aws --version

RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
