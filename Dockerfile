FROM jupyter/scipy-notebook

USER root

# Install opencv prerequisites...
RUN apt-get update -qq && apt-get install -y --force-yes \
    curl \
    git \
    g++ \
    autoconf \
    automake \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    libtool \
    v4l-utils \
    wget \
    tmux \
    unzip \
    libtiff5-dev \
    libpng-dev \
    libjpeg-dev \
    libjasper-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libv4l-dev \
    libtbb-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libtheora-dev \
    libxml2-dev \
    libxslt1-dev \
    libgeos-dev; \
    apt-get clean

# Build OpenCV 3.3.0
# =================================

WORKDIR /usr/local/src
RUN git clone --branch 3.3.0 --depth 1 https://github.com/opencv/opencv.git
RUN git clone --branch 3.3.0 --depth 1 https://github.com/opencv/opencv_contrib.git
RUN mkdir -p opencv/release
WORKDIR /usr/local/src/opencv/release
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D WITH_V4L=OFF \
          -D INSTALL_PYTHON_EXAMPLES=OFF \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_DOCS=OFF \
          -D WITH_XIMEA=OFF \
          -D WITH_QT=OFF \
          -D WITH_FFMPEG=OFF \
          -D WITH_PVAPI=YES \
          -D WITH_GSTREAMER=OFF \
          -D WITH_TIFF=YES \
          -D WITH_OPENCL=YES \
          -D WITH_1394=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D BUILD_PYTHON_SUPPORT=ON \
          -D BUILD_opencv_python2=ON \
          -D PYTHON2_EXECUTABLE=/opt/conda/envs/python2/bin/python \
          -D PYTHON2_INCLUDE_DIR=/opt/conda/envs/python2/include/python2.7 \
          -D PYTHON2_LIBRARIES=/opt/conda/envs/python2/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=/opt/conda/envs/python2/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=/opt/conda/envs/python2/lib/python2.7/site-packages/numpy/core/include/ \
          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
          -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.6m/ \
          -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
          -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.so \
          -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.6/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.6/site-packages/numpy/core/include/ \
          ..
RUN make -j4
RUN make install
RUN sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
RUN ldconfig

## Additional python modules
RUN /opt/conda/envs/python2/bin/pip install imutils imgaug shapely
RUN /opt/conda/bin/pip install imutils imgaug shapely

## =================================

## Post install mods:
# Bug in Anaconda distribution causes `GLIBC_2.15' not found error. Here is workaround:
RUN [ -e /opt/conda/lib/libm.so ] && mv /opt/conda/lib/libm.so /opt/conda/lib/libmXXX.so || exit 0
RUN [ -e /opt/conda/lib/libm.so.6 ] && mv /opt/conda/lib/libm.so.6 /opt/conda/lib/libm.so.6XXX || exit 0

## Switch back to jupyter user (for now)
USER jovyan

WORKDIR /data
