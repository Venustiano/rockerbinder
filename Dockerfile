FROM rocker/binder:4.4.2

## Declares build arguments
ARG NB_USER
ARG NB_UID

COPY --chown=${NB_USER} . ${HOME}

ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing > /dev/null\
        && xargs -a apt.txt apt-get install --yes \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
        ; fi

# Install Python dependencies for PyTorch
# Ensure pip is upgraded and install PyTorch
RUN apt-get update && apt-get install -y python3-pip \
    && python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install torch huggingface_hub
    
USER ${NB_USER}

## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi
