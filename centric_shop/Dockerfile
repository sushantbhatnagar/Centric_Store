# Use Ubuntu as the base image
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

USER root

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gpg \
    xvfb \
    libxi6 \
    libgconf-2-4 \
    libxcursor1 \
    libxss1 \
    libxrandr2 \
    libxcomposite1 \
    libasound2 \
    libxtst6 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libatk1.0-0 \
    libnss3 \
    libgbm-dev \
    libx11-xcb1 \
    git \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    x11-xserver-utils \
    xorg \
    xinit \
    xserver-xorg-video-dummy \
    xfonts-base

# Add the OpenJDK PPA
RUN add-apt-repository -y ppa:openjdk-r/ppa && apt-get update

# Install OpenJDK 11
RUN apt-get install -y openjdk-11-jdk

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$PATH:$JAVA_HOME/bin"

# Install Chrome browser
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable xvfb
ENV CHROME_BIN='/usr/bin/google-chrome-stable'

# Install ChromeDriver
RUN BROWSER_MAJOR=$(google-chrome --version | sed 's/Google Chrome \([0-9]*\).*/\1/g') && \
    wget https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${BROWSER_MAJOR} -O chrome_version && \
    wget https://chromedriver.storage.googleapis.com/`cat chrome_version`/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/ && \
    DRIVER_MAJOR=$(chromedriver --version | sed 's/ChromeDriver \([0-9]*\).*/\1/g') && \
    echo "chrome version: $BROWSER_MAJOR" && \
    echo "chromedriver version: $DRIVER_MAJOR" && \
    if [ $BROWSER_MAJOR != $DRIVER_MAJOR ]; then echo "VERSION MISMATCH"; exit 1; fi

# Install Ruby
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests curl bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/sstephenson/ruby-build/archive/v20221124.tar.gz | tar -zxvf - -C /tmp/ && \
    cd /tmp/ruby-build-* && ./install.sh && cd / && \
    ruby-build -v 3.1.3 /usr/local && rm -rfv /tmp/ruby-build-* && \
    gem install bundler

# XVFB
ENV DISPLAY=:1
RUN Xvfb :1 -screen 0 1600x1200x16 &
RUN export DISPLAY=:1.0

# Add Docker's official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Set environment variables
ENV PATH="/usr/local/bin:${PATH}"
ENV LANG C.UTF-8

# Set up a user
RUN useradd -ms /bin/bash slave
RUN usermod -aG sudo slave
USER slave

# Set the working directory
#WORKDIR /app
#
#COPY . /app

# Specify any additional commands or scripts you want to run

# Build your application inside the Docker container

# Example: Install Ruby dependencies using Bundler
# COPY Gemfile Gemfile.lock ./
# RUN bundle install

# Example: Copy your application code into the container
# COPY . .

# Expose any necessary ports

# Example: Expose port 3000 for a web application
# EXPOSE 3000

# Specify the command to run when the container starts

# Example: Start a Ruby web server
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# Note: Uncomment and modify the relevant lines based on your specific requirements