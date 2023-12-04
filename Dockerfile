FROM ubuntu:latest

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop

RUN rm /run/reboot-required*

# Update and install required packages for adding the Wine repository
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget

# Add the Wine repository
RUN dpkg --add-architecture i386
RUN wget -qO- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
RUN add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'

# Update again to refresh package lists with the new repository
RUN apt-get update

# Install Wine
RUN apt-get install -y winehq-stable

RUN useradd -m testuser -p $(openssl passwd 1234)
RUN usermod -aG sudo testuser

RUN apt install -y xrdp
RUN adduser xrdp ssl-cert

RUN sed -i '3 a echo "\
export GNOME_SHELL_SESSION_MODE=ubuntu\\n\
export XDG_SESSION_TYPE=x11\\n\
export XDG_CURRENT_DESKTOP=ubuntu:GNOME\\n\
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg\\n\
" > ~/.xsessionrc' /etc/xrdp/startwm.sh

EXPOSE 3389

# Copy your Windows executable file(s) into the container (assuming they are in the same directory as the Dockerfile)
COPY exness4setup.exe /app/
COPY MQL4 /app/

CMD service dbus start; /usr/lib/systemd/systemd-logind & service xrdp start ; bash
