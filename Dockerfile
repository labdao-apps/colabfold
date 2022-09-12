# FROM ubuntu:focal
FROM --platform=linux/amd64 nvidia/cuda:11.6.0-devel-ubuntu20.04 

# installing packages required for installation
RUN echo "downloading basic packages for installation"
RUN apt-get update
RUN apt-get install -y tmux wget curl git
RUN apt-get install -y libstdc++6 gcc

# checking installation of tools
RUN gcc --version
RUN nvcc --version

WORKDIR /src

RUN wget -q -P . https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /src/conda
RUN rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/src/conda/condabin:${PATH}"
RUN conda create --name colabfold-conda python=3.7 -y
# Switch to the new environment:
SHELL ["conda", "run", "-n", "colabfold-conda", "/bin/bash", "-c"] 
RUN conda update -n base conda -y

RUN pip install "colabfold[alphafold] @ git+https://github.com/sokrypton/ColabFold"
RUN pip install -q "jax[cuda]>=0.3.8,<0.4" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
# For template-based predictions also install kalign and hhsuite
RUN conda install -c conda-forge -c bioconda kalign2=2.04 hhsuite=3.3.0
# For amber also install openmm and pdbfixer
RUN conda install -c conda-forge openmm=7.5.1 pdbfixer

COPY . .
CMD ["bash"]