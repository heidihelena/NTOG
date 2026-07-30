FROM rocker/shiny:4.4.2

RUN install2.r --error --skipinstalled \
    bslib \
    digest \
    dplyr \
    ggplot2 \
    jsonlite \
    officer \
    readr \
    rvg \
    scales \
    svglite \
    testthat \
    zip

COPY . /srv/shiny-server/

RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838

CMD ["Rscript", "/srv/shiny-server/start.R"]
