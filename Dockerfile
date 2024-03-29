FROM debian:jessie

WORKDIR /root/work

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN apt-get install -y vim-nox
RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.8.5/gcc-4.8.5.tar.gz
RUN tar xvf gcc-4.8.5.tar.gz
WORKDIR gcc-4.8.5
RUN contrib/download_prerequisites
WORKDIR ..
RUN mkdir build_gcc-4.8.5
WORKDIR build_gcc-4.8.5/
RUN ../gcc-4.8.5/configure --prefix=/usr/local/gcc/gcc-4.8.5 --enable-languages=c,c++ --disable-bootstrap --disable-multilib
RUN make
RUN make install
ENV LIBRARY_PATH /usr/local/gcc/gcc-4.8.5/lib64
ENV PATH /usr/local/gcc/gcc-4.8.5/bin:$PATH
WORKDIR ..
RUN rm -f gcc-4.8.5.tar.gz
RUN rm -rf gcc-4.8.5
RUN rm -rf build_gcc-4.8.5
RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.7.4/gcc-4.7.4.tar.gz
RUN tar xvf gcc-4.7.4.tar.gz
WORKDIR gcc-4.7.4
RUN contrib/download_prerequisites
WORKDIR ..
RUN mkdir build_gcc-4.7.4
WORKDIR build_gcc-4.7.4/
RUN ../gcc-4.7.4/configure --prefix=/usr/local/gcc/gcc-4.7.4 --enable-languages=c,c++ --disable-bootstrap --disable-multilib
RUN make
RUN make install
ENV LIBRARY_PATH /usr/local/gcc/gcc-4.7.4/lib64
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH /usr/local/gcc/gcc-4.7.4/bin:$PATH
WORKDIR ..
RUN rm -f gcc-4.7.4.tar.gz
RUN rm -rf gcc-4.7.4
RUN rm -rf build_gcc-4.7.4
RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.6.4/gcc-4.6.4.tar.gz
RUN tar xvf gcc-4.6.4.tar.gz
WORKDIR gcc-4.6.4
RUN contrib/download_prerequisites
WORKDIR ..
RUN mkdir build_gcc-4.6.4
WORKDIR build_gcc-4.6.4/
RUN ../gcc-4.6.4/configure --prefix=/usr/local/gcc/gcc-4.6.4 --enable-languages=c,c++ --disable-bootstrap --disable-multilib
RUN make
RUN make install
ENV LIBRARY_PATH /usr/local/gcc/lib64
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH /usr/local/gcc/gcc-4.6.4/bin:$PATH
WORKDIR ..
RUN rm -f gcc-4.6.4.tar.gz
RUN rm -rf gcc-4.6.4
RUN rm -rf build_gcc-4.6.4
RUN curl -L https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.gz/download -o boost_1_61_0.tar.gz
RUN tar xvf boost_1_61_0.tar.gz
WORKDIR boost_1_61_0
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libbz2-dev
RUN apt-get install -y python-dev
RUN ./bootstrap.sh --prefix=/usr/local/boost
RUN ./b2 install 2>&1 | tee output.txt
ENV LD_LIBRARY_PATH /usr/local/boost/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH /usr/local/boost/lib:$LIBRARY_PATH
ENV CPATH /usr/local/boost/include:$CPATH
WORKDIR ..
RUN rm -f boost_1_61_0.tar.gz
RUN rm -rf boost_1_61_0
RUN apt-get install -y git
RUN apt-get install -y automake
RUN apt-get install -y libtool
RUN apt-get install -y flex
RUN apt-get install -y bison
RUN apt-get install -y ghostscript
RUN apt-get install -y python
RUN git clone -b v0.9.8.0 https://github.com/rose-compiler/rose rose
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
RUN apt-get install -y libtool-bin
RUN make pgms
RUN make DESTDIR=/usr/local/rosecheckers install
ENV PATH=/usr/local/rosecheckers/usr/bin:$PATH
WORKDIR ../..
RUN rm -rf rosecheckers-code

