################################################################################
#                             Dockerfile for Yocto Builds
#
# This container is based on the ubuntu:22.04 (LTS) image which is built and
# maintained by Ubuntu.
#
# This Dockerfile builds several layers that include:
#  -- locale
#  -- base linux utils
#  -- Visual Stuioe CODE (from MS)
#
# This container takes 20+ minutes for a clean build because it includes many
# additionala packages for Ubuntu and Yocto.
################################################################################

################################################################################
## Define the Ubuntu distro:
ARG UBUNTU_DISTRO="22.04"

##################################################################################
## Define the base image:
FROM ubuntu:${UBUNTU_DISTRO}

################################################################################
## USE en_US as prefix for USA
ARG LOCALE_PREFIX="en_US"
ARG LOCALE_SUFFIX="UTF-8"

ARG LOCALE_LANG=${LOCALE_PREFIX}.${LOCALE_SUFFIX}
ARG LOCALE_LC_ALL=${LOCALE_PREFIX}.${LOCALE_SUFFIX}

ENV LANG=${LOCALE_LANG}
ENV LC_ALL=${LOCALE_LC_ALL}

# Define the local docker user:
ARG USER_NAME=build
ARG USER_GROUP=build
ARG host_uid=6000
ARG host_gid=6000

##################################################################################
## Set locale and install packages as root:
USER root

##################################################################################
## Set the locale to: UTF-8
RUN  apt update \
  && apt install locales \
  && apt-get autoremove -y \
  && apt-get clean \
  && locale-gen ${LOCALE_PREFIX} ${LOCALE_LANG} \
  && update-locale LC_ALL=${LOCALE_LC_ALL} LANG=${LOCALE_LANG} \
  && export LANG=${LOCALE_LANG}


##################################################################################
## Install needed packages:

## The two items needed to TZDATA package:
#    DEBIAN_FRONTEND=noninteractive
#    TZ=Etc/UTC

RUN  apt-get update \
  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install \
       apt-transport-https \
       bash-completion \
       build-essential \
       chrpath \
       cpio \
       debianutils \
       diffstat \
       dirmngr \
       emacs \
       gawk wget \
       gcc-multilib \
       git \
       git-core \
       gnupg2 \
       gpg \
       iputils-ping \
       libsdl1.2-dev \
       locales \
       nano \
       net-tools \
       nfs-client \
       python3 \
       python3-pexpect \
       python3-pip \
       python-is-python3 \
       socat \
       ssh \
       sudo \
       tar \
       texinfo \
       tzdata \
       unzip \
       vim \
       wget \
       x11-apps \
       xterm \
       xz-utils \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip3 install --no-cache-dir --upgrade pip \
  && pip3 install kas==4.3.2


########################################################################
## To install VSCode: (or code-insiders)
RUN  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
  && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
  && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null \
  && rm -f packages.microsoft.gpg \
  && apt update \
  && apt install code -q -y \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


########################################################################
## Install ROS items:
ARG ROS_DISTRO="humble"
#ARG ROS_DISTRO="jazzy"

#RUN  apt update \
#  && apt install -q -y \
#        python3-colcon-common-extensions \
#        python3-colcon-mixin \
#        python3-rosdep \
#        python3-vcstool \
#        ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
#        ros-${ROS_DISTRO}-desktop \
#        ros-${ROS_DISTRO}-demo-nodes-cpp \
#        ros-${ROS_DISTRO}-demo-nodes-py \
#        ros-${ROS_DISTRO}-turtlesim \
#        ros-${ROS_DISTRO}-rosbag2* \
#        ~nros-${ROS_DISTRO}-rqt* \
#        ros-dev-tools \
#  && apt-get autoremove -y \
#  && apt-get clean
#  && rm -rf /var/lib/apt/lists/*


########################################################################
## The dash shell does not support the source command.
## However, we need the source command in the very last
## line of the Dockerfile.
RUN rm /bin/sh && ln -s bash /bin/sh


RUN groupadd -g $host_gid $USER_NAME \
  && useradd -g $host_gid -m -s /bin/bash -u $host_uid $USER_NAME


USER $USER_NAME

ENV BUILD_INPUT_DIR /home/$USER_NAME/yocto/input
ENV BUILD_OUTPUT_DIR /home/$USER_NAME/yocto/output
RUN mkdir -p $BUILD_INPUT_DIR $BUILD_OUTPUT_DIR

WORKDIR $BUILD_OUTPUT_DIR
ENV TEMPLATECONF=$BUILD_INPUT_DIR/$PROJECT/sources/meta-$PROJECT/custom
CMD source $BUILD_INPUT_DIR/$PROJECT/sources/poky/oe-init-build-env \
    build && bitbake $PROJECT-image

