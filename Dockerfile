FROM golang:1.14.5

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# install build essentials
RUN apt-get update && \
    apt-get install -y wget build-essential pkg-config --no-install-recommends

# Install ImageMagick deps
RUN apt-get -q -y install libjpeg-dev libpng-dev libtiff-dev libxml2 libwebp-dev librsvg2-bin zip unzip\
    libgif-dev libx11-dev libltdl-dev libtool-bin ocl-icd-opencl-dev libfreetype6 --no-install-recommends

ENV IMAGEMAGICK_VERSION=7.0.10-23

ENV POTRACE_VERSION=1.16

ENV FREETYPE_VERSION=2.10.2

ENV SWOOLE_VERSION=4.5.2

RUN cd && \
    wget https://nchc.dl.sourceforge.net/project/freetype/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz && \
    tar xvzf freetype-${FREETYPE_VERSION}.tar.gz && \
    cd freetype-${FREETYPE_VERSION} && \
    ./configure && \
    make && make install && \
    ldconfig /usr/local/lib

# ImageMagick
RUN cd && \
	wget https://github.com/ImageMagick/ImageMagick/archive/${IMAGEMAGICK_VERSION}.tar.gz && \
	tar xvzf ${IMAGEMAGICK_VERSION}.tar.gz && \
	cd ImageMagick* && \
	./configure \
	    --disable-opencl \
	    --disable-silent-rules \
	    --without-magick-plus-plus \
	    --with-freetype=yes \
	    --enable-shared \
	    --with-rsvg=yes \
	    --with-jpeg=yes \
        --with-png=yes \
	    --enable-static \
	    --with-modules=yes \
	    --enable-openmp \
	    --without-perl \
	    --with-modules \
        --with-webp=yes \
        --with-openjp2=yes \
        --with-openexr=yes \
        --with-librsvg=yes \
        --with-heic=yes \
	    --with-fontpath \
	    --disable-docs \
#	    ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp \
#	    ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp \
#	    LDFLAGS=-lomp \
	    && make -j$(nproc) && make install && \
	ldconfig /usr/local/lib

# php
RUN apt -y install lsb-release apt-transport-https ca-certificates && \
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
	apt update && \
	apt install -q -y composer php7.4 php7.4-dev php7.4-mysql php7.4-bcmath php7.4-bz2 php7.4-curl php7.4-gd php7.4-mbstring php7.4-zip php7.4-xmlreader

# php protobuf
RUN pecl install protobuf && \
	echo "extension=protobuf" > /etc/php/7.4/cli/conf.d/20-protobuf.ini
# php imagick
RUN echo "" | pecl install imagick && \
	echo "extension=imagick" > /etc/php/7.4/cli/conf.d/20-imagick.ini
# php igbinary
RUN echo no | pecl install igbinary && \
	echo "extension=igbinary" > /etc/php/7.4/cli/conf.d/20-igbinary.ini
# php redis
RUN echo yes | pecl install redis && \
	echo "extension=redis" > /etc/php/7.4/cli/conf.d/20-redis.ini
# php swoole
RUN cd && \
	wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz && \
	tar xvzf v${SWOOLE_VERSION}.tar.gz && \
	cd swoole* && \
	phpize && \
	./configure  --enable-openssl --enable-sockets --enable-http2 --enable-mysqlnd && \
	make && make install && \
	echo "extension=swoole" > /etc/php/7.4/cli/conf.d/20-swoole.ini

RUN cd && \
	wget  https://downloads.sourceforge.net/potrace/potrace-${POTRACE_VERSION}.tar.gz && \
	tar xvzf potrace-${POTRACE_VERSION}.tar.gz && \
	cd potrace* && \
	./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/potrace \
                --enable-a4 \
                --enable-metric \
                --with-libpotrace && \
    make && make install && \
	ldconfig /usr/local/lib

# Install potrace to transform png to svg
#RUN apt-get -q -y install potrace

# svg to image
RUN apt-get -q -y install python3 python3-pip default-jdk
RUN pip3 install cairosvg

# mini size
RUN apt-get clean autoclean \
	&& apt-get autoremove --yes \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/



RUN go get github.com/allegro/bigcache
RUN go get github.com/astaxie/beego/orm
RUN go get github.com/go-sql-driver/mysql
RUN go get github.com/ghodss/yaml
RUN go get github.com/json-iterator/go
RUN go get gopkg.in/gographics/imagick.v3/imagick
#RUN go get github.com/gobuffalo/packr/v2
RUN go get github.com/gobuffalo/packr
RUN go get github.com/gobuffalo/packd
RUN go get github.com/sirupsen/logrus
RUN go get github.com/gobuffalo/logger
RUN go get github.com/karrick/godirwalk
RUN go get github.com/gobuffalo/envy
RUN go get github.com/google/uuid
RUN go get github.com/pkg/errors
RUN go get github.com/nats-io/nats.go
RUN go get github.com/go-redis/redis
RUN go get github.com/esap/wechat

RUN go get github.com/markbates/pkger/cmd/pkger
RUN go get github.com/markbates/safe
RUN go get github.com/markbates/errx
RUN go get github.com/markbates/oncer

RUN go get github.com/gin-gonic/gin
RUN go get github.com/gorilla/websocket
RUN go get github.com/ipipdotnet/ipdb-go
RUN go get github.com/shirou/gopsutil
RUN go get github.com/beevik/etree
RUN go get github.com/siongui/gojianfan
RUN go get github.com/gin-contrib/pprof


VOLUME /go/build/

WORKDIR /go/run

COPY logo-text-svg-0.0.7.jar /go/run

