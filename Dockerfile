FROM ubuntu:18.04
MAINTAINER Cody Hiar <codyfh@gmail.com>

########################################
# System Stuff
########################################

# Better terminal support
ENV TERM screen-256color
ENV DEBIAN_FRONTEND noninteractive

# Update and install
RUN apt-get update && apt-get install -y \
      htop \
      bash \
      curl \
      wget \
      git \
      software-properties-common \
      python-dev \
      python-pip \
      python3-dev \
      python3-pip \
      ctags \
      shellcheck \
      netcat \
      ack-grep \
      sqlite3 \
      unzip \
      # For python crypto libraries
      libssl-dev \
      libffi-dev \
      locales \
      # For Youcompleteme
      cmake

# Generally a good idea to have these, extensions sometimes need them
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Neovim
RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update && apt-get install -y \
      neovim

# Install Ledger
RUN add-apt-repository ppa:mbudde/ledger
RUN apt-get update && apt-get install -y \
      ledger

# Install Terraform for linting
RUN wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip && \
    unzip terraform_0.11.8_linux_amd64.zip && \
    mv terraform /usr/bin

# Ubuntu ranger old and doesn't support 'wrap_scroll'.
RUN git clone https://github.com/thornycrackers/ranger.git /tmp/ranger && \
    cd /tmp/ranger && \
    make install

########################################
# Python
########################################

# Install python linting and neovim plugin
ADD py2_requirements.txt /opt/py2_requirements.txt
RUN cd /opt && pip2 install -r py2_requirements.txt

ADD py3_requirements.txt /opt/py3_requirements.txt
RUN cd /opt && pip3 install -r py3_requirements.txt


########################################
# Personalizations
########################################
# Setup non root user
RUN groupadd -g 1000 thorny
RUN useradd -m -d /home/thorny -s /bin/bash -g thorny -u 1000 thorny
USER thorny
# Add some aliases
COPY --chown=thorny bashrc /home/thorny/.bashrc
# Add my git config
COPY --chown=thorny gitconfig /home/thorny/.gitconfig
# Neovim needs this so that <ctrl-h> can work
RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /home/thorny/$TERM.ti
RUN tic /home/thorny/$TERM.ti
# Command for the image
CMD ["/bin/bash"]
# Add nvim config. Put this last since it changes often
COPY --chown=thorny nvim /home/thorny/.config/nvim
# Install neovim plugins
RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
RUN cd /home/thorny/.config/nvim/plugged/YouCompleteMe && python3 install.py
# Add flake8 config, don't trigger a long build process
COPY --chown=thorny flake8 /home/thorny/.flake8
# Add local vim-options, can override the one inside
COPY --chown=thorny vim-options /home/thorny/.config/nvim/plugged/vim-options
# Add isort config, also changes often
COPY --chown=thorny isort.cfg /home/thorny/.isort.cfg
# Add ranger config
COPY --chown=thorny rc.conf /home/thorny/.config/ranger/rc.conf
# Set the workdir
WORKDIR /src
