name             'centos-gnome-tigervnc'
maintainer       'Lonnie VanZandt'
maintainer_email 'lonniev@gmail.com'
license          'Apache 2.0'
description      'Yum installs the GNOME Desktop and TigerVNC'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

%w( centos redhat fedora )
.each do |os|
  supports os
end

recipe 'centos-gnome-tigervnc::default', 'Yum installs the GNOME Desktop and TigerVNC'

depends 'yumgroup'
