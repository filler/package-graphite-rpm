#! /bin/bash

#
# This script needs "fpm". If you dont have it,
# run "gem install fpm"
#
# You also need to "yum install python-setuptools" (otherwise fpm fails)
#
# There is also the need for epel packages (Django, django-tagging, 
# python-sqlite2) at install
#
# This is heavily inspired from the deb-based script
# at https://gist.github.com/1715985.  Thanks for that.
#

VER="0.9.10"
PACKAGER="Yale University <dcsunix@yale.edu>" 

clean() {
    rm -rf whisper-${VER} carbon-${VER} graphite-web-${VER}
    rm -f python*.rpm
}

download() {
    [ -e graphite-web-${VER}.tar.gz ] || wget http://launchpad.net/graphite/0.9/${VER}/+download/graphite-web-${VER}.tar.gz
    [ -e carbon-${VER}.tar.gz ]       || wget http://launchpad.net/graphite/0.9/${VER}/+download/carbon-${VER}.tar.gz
    [ -e whisper-${VER}.tar.gz ]      || wget http://launchpad.net/graphite/0.9/${VER}/+download/whisper-${VER}.tar.gz
}

extract() {
    tar -zxf graphite-web-${VER}.tar.gz
    tar -zxf carbon-${VER}.tar.gz
    tar -zxf whisper-${VER}.tar.gz
}

package() {
#    fpm -s python -t rpm --depends "python-twisted-core" txamqp

    fpm -n "whisper" -m "${PACKAGER}" -s python -t rpm \
	--depends "python" \
	--depends "python-devel" \
	--depends "python-setuptools" \
	whisper-${VER}/setup.py

    fpm -n "carbon" -m "${PACKAGER}" -s python -t rpm \
	--depends "python" \
	--depends "python-devel" \
	--depends "python-setuptools" \
	--depends "python-twisted-core" \
	carbon-${VER}/setup.py

    fpm -n "graphite-web" -m "${PACKAGER}" -s python -t rpm \
	--depends "Django" \
	--depends "django-tagging" \
	--depends "httpd" \
	--depends "mod_wsgi" \
	--depends "pycairo" \
	--depends "python" \
	--depends "python-devel" \
	--depends "python-setuptools" \
	--depends "python-simplejson" \
	--depends "python-sqlite2" \
	graphite-web-${VER}/setup.py
}

install() {
    sudo yum -y install carbon*.rpm whisper*.rpm graphite-web*.rpm
}

uninstall() {
    sudo yum -y remove carbon whisper graphite-web
}

uninstall
download
clean
extract
package
install
