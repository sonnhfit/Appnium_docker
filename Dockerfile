ARG BASE_IMAGE=ubuntu:bionic-20200807
FROM $BASE_IMAGE
ENV BASE_IMAGE=$BASE_IMAGE

ENV DEBIAN_FRONTEND=noninteractive

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# openjdk-8-jdk
#   Java
# ca-certificates
#   SSL client
# tzdata
#   Timezone
# zip
#   Make a zip file
# unzip
#   Unzip zip file
# curl
#   Transfer data from or to a server
# wget
#   Network downloader
# libqt5webkit5
#   Web content engine (Fix issue in Android)
# libgconf-2-4
#   Required package for chrome and chromedriver to run on Linux
# xvfb
#   X virtual framebuffer
# gnupg
#   Encryption software. It is needed for nodejs
# salt-minion
#   Infrastructure management (client-side)
#==================
RUN apt-get -qqy update && \
    apt-get -qqy --no-install-recommends install \
    openjdk-8-jdk \
    ca-certificates \
    tzdata \
    zip \
    unzip \
    curl \
    wget \
    libqt5webkit5 \
    libgconf-2-4 \
    xvfb \
    gnupg \
    salt-minion \
    && rm -rf /var/lib/apt/lists/*

#===============
# Set JAVA_HOME
#===============
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" \
    PATH=$PATH:$JAVA_HOME/bin

#=====================
# Install Android SDK
#=====================
ARG SDK_VERSION=commandlinetools-linux-6609375_latest
ARG ANDROID_BUILD_TOOLS_VERSION=29.0.3
ARG ANDROID_PLATFORM_VERSION="android-29"

ENV SDK_VERSION=$SDK_VERSION \
    ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION \
    ANDROID_HOME=/root

RUN wget -O tools.zip https://dl.google.com/android/repository/${SDK_VERSION}.zip && \
    unzip tools.zip -d /root/cmdline-tools && rm tools.zip && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools:$ANDROID_HOME/cmdline-tools/tools/bin

# https://askubuntu.com/questions/885658/android-sdk-repositories-cfg-could-not-be-loaded
RUN mkdir -p ~/.android && \
    touch ~/.android/repositories.cfg
RUN echo y | sdkmanager "platform-tools"
RUN echo y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
RUN echo y | sdkmanager "platforms;$ANDROID_PLATFORM_VERSION"

ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

#====================================
# Install latest nodejs, npm, appium
# Using this workaround to install Appium -> https://github.com/appium/appium/issues/10020 -> Please remove this workaround asap
#====================================
ARG APPIUM_VERSION=1.18.1
ENV APPIUM_VERSION=$APPIUM_VERSION

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash && \
    apt-get -qqy install nodejs && \
    npm install -g appium@${APPIUM_VERSION} --unsafe-perm=true --allow-root && \
    npm install -g pm2@4.4.1 && \
    exit 0 && \
    npm cache clean && \
    apt-get remove --purge -y npm && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean

#================================
# APPIUM Test Distribution (ATD)
#================================
ARG ATD_VERSION=1.2
ENV ATD_VERSION=$ATD_VERSION
# RUN wget -nv -O RemoteAppiumManager.jar "https://github.com/AppiumTestDistribution/ATD-Remote/releases/download/${ATD_VERSION}/RemoteAppiumManager-${ATD_VERSION}.jar"
COPY core/lib/RemoteAppiumManager-1.2.jar /root/

#==================================
# Fix Issue with timezone mismatch
#==================================
ENV TZ="US/Pacific"
RUN echo "${TZ}" > /etc/timezone

#===============
# Expose Ports
#---------------
# 4723
#   Appium port
# 4567
#   ATD port
#===============
EXPOSE 4723
EXPOSE 4567

#====================================================
# Scripts to run appium and connect to Selenium Grid
#====================================================
COPY Scripts/entry_point.sh \
    Scripts/generate_config.sh \
    Scripts/wireless_connect.sh \
    Scripts/wireless_autoconnect.sh \
    Scripts/run_tasks.sh \
    /root/

COPY . /app

RUN chmod +x /root/entry_point.sh && \
    chmod +x /root/generate_config.sh && \
    chmod +x /root/wireless_connect.sh && \
    chmod +x /root/wireless_autoconnect.sh && \
    chmod +x /root/run_tasks.sh

#========================================
# Run xvfb and appium server
#========================================
CMD /root/wireless_autoconnect.sh && /root/entry_point.sh
