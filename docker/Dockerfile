FROM rocker/rstudio:3.6.0

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y --no-install-recommends libhiredis-dev

WORKDIR /tmp
COPY install.R .
RUN R -f install.R
WORKDIR /

COPY manager.R /home/rstudio/
COPY worker.R /home/rstudio/

COPY 01-Renviron /etc/cont-init.d/01-Renviron

