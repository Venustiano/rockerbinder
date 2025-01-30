FROM rocker/binder:4.4.2

## Declares build arguments
ARG NB_USER
ARG NB_UID

ENV HOME=/home/rstudio

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

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Set LD_LIBRARY_PATH for Java
ENV LD_LIBRARY_PATH=/usr/lib/jvm/java-21-openjdk-amd64/lib/server:$LD_LIBRARY_PATH

# Configure R with Java support
RUN R CMD javareconf
RUN chown -R ${NB_USER}:${NB_USER} /opt/venv
USER ${NB_USER}

# Install Python dependencies for PyTorch
# Ensure pip is upgraded and install PyTorch
RUN python3 -m pip install --no-cache-dir --upgrade pip \
        torch \
        huggingface_hub \
        transformers \
        sentence-transformers \
        numpy \
        scikit-learn \
        pandas \
        matplotlib \
        wordcloud \
        nltk \
    && python -m nltk.downloader punkt


## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi
