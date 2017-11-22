#
# Cookbook Name:: centos-gnome-tigervnc
# Recipe:: default
#
# Author:: Lonnie VanZandt <lonniev@gmail.com>
# Copyright 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# GNOME Desktop packages
yumgroup "GNOME Desktop"

# the VNC package(s)
%w(
  tigervnc-server )
.each do |pkg|
  yum_package pkg.to_s
end

# set the system to default to initializing the GUI environment
execute 'default to graphical.target' do
  command "systemctl set-default graphical.target"
end

file "/tmp/gtk.css" do
  owner 'oracle'
  group 'oracle'
  mode '0755'
  content <<~HERE
    headerbar entry,
    headerbar spinbutton,
    headerbar button,
    headerbar separator {
        margin-top: 0px; /* same as headerbar side padding for nicer proportions */
        margin-bottom: 0px;
    }

    headerbar {
        min-height: 24px;
        padding-left: 2px; /* same as childrens vertical margins for nicer proportions */
        padding-right: 2px;
        margin: 0px; /* same as headerbar side padding for nicer proportions */
        padding: 0px;
    }

    .default-decoration .titlebutton {
        min-height: 26px; /* tweak these two props to reduce button size */
        min-width: 26px;
    }

    window.ssd headerbar.titlebar {
      border: none;
      background-image: linear-gradient(to bottom,
      shade(@theme_bg_color, 1.05),
      shade(@theme_bg_color, 0.99));
      box-shadow: inset 0 1px shade(@theme_bg_color, 1.4);
    }
  HERE
end

file "/tmp/Xstartup" do
  content <<~HERE
    #!/bin/sh
    # Uncomment the following two lines for normal desktop:
    # unset SESSION_MANAGER
    # exec /etc/X11/xinit/xinitrc
    [ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
    [ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
    #xsetroot -solid grey
    #vncconfig -iconic &
    #xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
    #twm &
    if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
            eval `dbus-launch --sh-syntax --exit-with-session`
            echo "D-BUS per-session daemon address is: \
            $DBUS_SESSION_BUS_ADDRESS"
    fi
    exec gnome-session
  HERE
end

file "/etc/systemd/system/vncserver@:1.service" do
  content <<~HERE
    [Unit]
    Description=Remote desktop service (VNC)
    After=syslog.target network.target

    [Service]
    Environment=XDG_SESSION_TYPE=x11
    Type=forking
    User=lonniev

    # Clean any existing files in /tmp/.X11-unix environment
    ExecStartPre=-/usr/bin/vncserver -kill %i
    ExecStart=/usr/bin/vncserver %i
    PIDFile=/home/lonniev/.vnc/%H%i.pid
    ExecStop=-/usr/bin/vncserver -kill %i

    [Install]
    WantedBy=multi-user.target
  HERE
end
