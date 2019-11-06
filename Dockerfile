FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# Update apt repositories and install necessary apt packages
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Anaconda3
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    cp ~/.bashrc /etc/bash.bashrc && \
    chmod 777 /etc/bash.bashrc

# Make jupyter lab working directory
RUN mkdir -p /jupyter-lab && chmod 777 /jupyter-lab

# Install python packages
RUN conda update -y conda && \
    conda install -y tensorflow-gpu=2.0.0 nodejs black && \
    conda update -y jupyterlab && \
    conda install -y -c conda-forge jupyterlab_code_formatter && \
    jupyter serverextension enable --py jupyterlab_code_formatter && \
    conda clean -y -a

VOLUME ["/opt/conda/share/jupyter/lab", "/root/.jupyter", "/jupyter-lab"]
WORKDIR /jupyter-lab
EXPOSE 8888

ENTRYPOINT ["/bin/bash", "-c", "source /etc/bash.bashrc && jupyter lab --ip 0.0.0.0 --no-browser --allow-root"]
