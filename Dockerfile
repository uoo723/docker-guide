FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# Update apt repositories and install necessary apt packages
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

# Install Anaconda3
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    cp ~/.bashrc /etc/bash.bashrc && \
    chmod 777 /etc/bash.bashrc

# Install tensorflow-gpu
RUN conda install -y tensorflow-gpu=2.0.0 && conda clean -y -a

# Make jupyter lab working directory
RUN mkdir -p /jupyter-lab && chmod 777 /jupyter-lab

# Install tini (tiny init)
RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /jupyter-lab
EXPOSE 8888

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash", "-c", "source /etc/bash.bashrc && jupyter lab --ip 0.0.0.0 --no-browser --allow-root" ]
