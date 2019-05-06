FROM rocker/r-ver:3.6.0

RUN apt-get update && apt-get install -y --no-install-recommends libhiredis-dev

WORKDIR /tmp
COPY install.R .
RUN R -f install.R
WORKDIR /

COPY manager.R .
COPY worker.R .

CMD ["/bin/bash"]
