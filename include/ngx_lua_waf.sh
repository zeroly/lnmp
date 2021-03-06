#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Nginx_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${nginx_install_dir}/sbin/nginx" ] && echo "${CWARNING}Nginx is not installed on your system! ${CEND}" && exit 1
  if [ ! -e "/usr/local/lib/libluajit-5.1.so.2.1.0" ]; then
    [ -e "/usr/local/lib/libluajit-5.1.so.2.0.5" ] && find /usr/local -name *luajit* | xargs rm -rf
    src_url=http://mirrors.linuxeye.com/oneinstack/src/LuaJIT-2.1.0-beta3.tar.gz && Download_src
    tar xzf LuaJIT-2.1.0-beta3.tar.gz
    pushd LuaJIT-2.1.0-beta3
    make && make install
    popd > /dev/null
  fi
  if [ ! -e "/usr/local/lib/lua/5.1/cjson.so" ]; then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-cjson-2.1.0.6.tar.gz && Download_src
    tar xzf lua-cjson-2.1.0.6.tar.gz
    pushd lua-cjson-2.1.0.6
    sed -i 's@LUA_INCLUDE_DIR.*@LUA_INCLUDE_DIR \?=   \$(PREFIX)/include/luajit-2.1@' Makefile
    make && make install
    popd > /dev/null
  fi
  ${nginx_install_dir}/sbin/nginx -V &> $$
  nginx_configure_args_tmp=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
  rm -rf $$
  nginx_configure_args=`echo ${nginx_configure_args_tmp} | sed "s@--with-openssl=../openssl-...... @--with-openssl=../openssl-${openssl_ver} @" | sed "s@--with-pcre=../pcre-.... @--with-pcre=../pcre-${pcre_ver} @"`
  if [ -z "`echo ${nginx_configure_args} | grep lua-nginx-module`" ]; then
    src_url=http://nginx.org/download/nginx-${nginx_ver}.tar.gz && Download_src
    src_url=https://www.openssl.org/source/openssl-${openssl_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/ngx_devel_kit.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-nginx-module.tar.gz && Download_src
    tar xzf nginx-${nginx_ver}.tar.gz
    tar xzf openssl-${openssl_ver}.tar.gz
    tar xzf pcre-${pcre_ver}.tar.gz
    tar xzf ngx_devel_kit.tar.gz
    tar xzf lua-nginx-module.tar.gz
    pushd nginx-${nginx_ver}
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1
    ./configure ${nginx_configure_args} --add-module=../lua-nginx-module --add-module=../ngx_devel_kit
    make -j ${THREAD}
    if [ -f "objs/nginx" ]; then
      /bin/mv ${nginx_install_dir}/sbin/nginx{,`date +%m%d`}
      /bin/cp objs/nginx ${nginx_install_dir}/sbin/nginx
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "${CSUCCESS}lua-nginx-module installed successfully! ${CEND}"
      rm -rf nginx-${nginx_ver}
    else
      echo "${CFAILURE}lua-nginx-module install failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Tengine_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${tengine_install_dir}/sbin/nginx" ] && echo "${CWARNING}Tengine is not installed on your system! ${CEND}" && exit 1
  if [ ! -e "/usr/local/lib/libluajit-5.1.so.2.1.0" ]; then
    [ -e "/usr/local/lib/libluajit-5.1.so.2.0.5" ] && find /usr/local -name *luajit* | xargs rm -rf
    src_url=http://mirrors.linuxeye.com/oneinstack/src/LuaJIT-2.1.0-beta3.tar.gz && Download_src
    tar xzf LuaJIT-2.1.0-beta3.tar.gz
    pushd LuaJIT-2.1.0-beta3
    make && make install
    popd > /dev/null
  fi
  if [ ! -e "/usr/local/lib/lua/5.1/cjson.so" ]; then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-cjson-2.1.0.6.tar.gz && Download_src
    tar xzf lua-cjson-2.1.0.6.tar.gz
    pushd lua-cjson-2.1.0.6
    sed -i 's@LUA_INCLUDE_DIR.*@LUA_INCLUDE_DIR \?=   \$(PREFIX)/include/luajit-2.1@' Makefile
    make && make install
    popd > /dev/null
  fi
  ${tengine_install_dir}/sbin/nginx -V &> $$
  tengine_configure_args_tmp=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
  rm -rf $$
  tengine_configure_args=`echo ${tengine_configure_args_tmp} | sed "s@--with-openssl=../openssl-...... @--with-openssl=../openssl-${openssl_ver} @" | sed "s@--with-pcre=../pcre-.... @--with-pcre=../pcre-${pcre_ver} @"`
  if [ -z "`echo ${tengine_configure_args} | grep lua`" ]; then
    src_url=http://tengine.taobao.org/download/tengine-${tengine_ver}.tar.gz && Download_src
    src_url=https://www.openssl.org/source/openssl-${openssl_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/ngx_devel_kit.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-nginx-module.tar.gz && Download_src
    tar xzf tengine-${tengine_ver}.tar.gz
    tar xzf openssl-${openssl_ver}.tar.gz
    tar xzf pcre-${pcre_ver}.tar.gz
    tar xzf ngx_devel_kit.tar.gz
    tar xzf lua-nginx-module.tar.gz
    pushd tengine-${tengine_ver}
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1
    ./configure ${tengine_configure_args} --add-module=../lua-nginx-module --add-module=../ngx_devel_kit
    make -j ${THREAD}
    if [ -f "objs/nginx" ]; then
      /bin/mv ${tengine_install_dir}/sbin/nginx{,`date +%m%d`}
      /bin/mv ${tengine_install_dir}/sbin/dso_tool{,`date +%m%d`}
      /bin/mv ${tengine_install_dir}/modules{,`date +%m%d`}
      /bin/cp objs/nginx ${tengine_install_dir}/sbin/nginx
      /bin/cp objs/dso_tool ${tengine_install_dir}/sbin/dso_tool
      chmod +x ${tengine_install_dir}/sbin/*
      make install
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "${CSUCCESS}lua_module installed successfully! ${CEND}"
      rm -rf tengine-${tengine_ver}
    else
      echo "${CFAILURE}lua_module install failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

enable_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  . ../include/check_dir.sh
  rm -f ngx_lua_waf.tar.gz
  src_url=http://mirrors.linuxeye.com/oneinstack/src/ngx_lua_waf.tar.gz && Download_src
  tar xzf ngx_lua_waf.tar.gz -C ${web_install_dir}/conf
  sed -i "s@/usr/local/nginx@${web_install_dir}@g" ${web_install_dir}/conf/waf.conf
  sed -i "s@/usr/local/nginx@${web_install_dir}@" ${web_install_dir}/conf/waf/config.lua
  sed -i "s@/data/wwwlogs@${wwwlogs_dir}@" ${web_install_dir}/conf/waf/config.lua
  [ -z "`grep 'include waf.conf;' ${web_install_dir}/conf/nginx.conf`" ] && sed -i "s@ vhost/\*.conf;@&\n  include waf.conf;@" ${web_install_dir}/conf/nginx.conf
  ${web_install_dir}/sbin/nginx -t
  if [ $? -eq 0 ]; then
    service nginx reload
    echo "${CSUCCESS}ngx_lua_waf enabled successfully! ${CEND}"
    chown ${run_user} ${wwwlogs_dir}
  else
    echo "${CFAILURE}ngx_lua_waf enable failed! ${CEND}"
  fi
  popd > /dev/null
}

disable_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  . ../include/check_dir.sh
  sed -i '/include waf.conf;/d' ${web_install_dir}/conf/nginx.conf
  ${web_install_dir}/sbin/nginx -t
  if [ $? -eq 0 ]; then
    rm -rf ${web_install_dir}/conf/{waf,waf.conf}
    service nginx reload
    echo "${CSUCCESS}ngx_lua_waf disabled successfully! ${CEND}"
  else
    echo "${CFAILURE}ngx_lua_waf disable failed! ${CEND}"
  fi
  popd > /dev/null
}
