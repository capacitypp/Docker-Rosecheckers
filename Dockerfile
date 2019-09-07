FROM debian:wheezy

WORKDIR /root/work

RUN echo 'deb http://archive.debian.org/debian wheezy main' > /etc/apt/sources.list
RUN echo 'deb http://archive.debian.org/debian-security wheezy/updates main' >> /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update
RUN apt-get install -y build-essential
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN apt-get install -y vim-nox
RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.6.4/gcc-4.6.4.tar.gz
RUN tar xvf gcc-4.6.4.tar.gz
WORKDIR gcc-4.6.4
RUN contrib/download_prerequisites
WORKDIR ..
RUN mkdir build_gcc
WORKDIR build_gcc/
RUN ../gcc-4.6.4/configure --prefix=/usr/local/gcc --enable-languages=c,c++ --disable-bootstrap --disable-multilib
RUN make
RUN make install
ENV LD_LIBRARY_PATH /usr/local/gcc/lib64:$LD_LIBRARY_PATH
ENV LIBRARY_PATH /usr/local/gcc/lib64:$LIBRARY_PATH
ENV PATH /usr/local/gcc/bin:$PATH
WORKDIR ..
RUN rm -f gcc-4.6.4.tar.gz
RUN rm -rf gcc-4.6.4
RUN rm -rf build_gcc
RUN curl -L https://sourceforge.net/projects/boost/files/boost/1.45.0/boost_1_45_0.tar.gz/download -o boost_1_45_0.tar.gz
RUN tar xvf boost_1_45_0.tar.gz
WORKDIR boost_1_45_0
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libbz2-dev
RUN apt-get install -y libicu-dev
RUN ./bootstrap.sh --prefix=/usr/local/boost
RUN ./bjam install 2>&1 | tee output.txt
ENV LD_LIBRARY_PATH /usr/local/boost/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH /usr/local/boost/lib:$LIBRARY_PATH
ENV CPATH /usr/local/boost/include:$CPATH
WORKDIR ..
RUN rm -f boost_1_45_0.tar.gz
RUN rm -rf boost_1_45_0
RUN apt-get install -y git
RUN apt-get install -y automake
RUN apt-get install -y libtool
RUN apt-get install -y flex
RUN apt-get install -y bison
RUN apt-get install -y ghostscript
RUN apt-get install -y python
RUN git clone -b v0.9.6.4 https://github.com/rose-compiler/rose rose
WORKDIR rose
RUN ./build
WORKDIR ..
RUN mkdir build_rose
WORKDIR build_rose
RUN ../rose/configure --prefix=/usr/local/rose --enable-languages=c,c++ --with-boost=/usr/local/boost
RUN make
RUN make install
WORKDIR ..
RUN rm -rf build_rose
RUN rm -rf rose
RUN apt-get install -y subversion
RUN svn checkout https://svn.code.sf.net/p/rosecheckers/code/trunk rosecheckers-code
WORKDIR rosecheckers-code/rosecheckers
RUN export ROSE=/usr/local/rose
RUN sed -i 's/) \$\^/) $^ -lboost_regex -lboost_system/' Makefile
ENV LD_LIBRARY_PATH /usr/local/rose/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH /usr/local/rose/lib:$LIBRARY_PATH
ENV CPATH /usr/local/rose/include:$CPATH
ENV CPATH /usr/local/rose/include/rose:$CPATH
RUN make pgms
RUN make DESTDIR=/usr/local/rosecheckers install
ENV PATH=/usr/local/rosecheckers/usr/bin:$PATH
WORKDIR ../..
RUN rm -rf rosecheckers-code

