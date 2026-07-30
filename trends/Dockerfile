FROM rocker/shiny:4.4.2

RUN install2.r --error --skipinstalled \
    bslib \
    dplyr \
    ggplot2 \
    jsonlite \
    readr \
    scales \
    testthat

COPY . /srv/shiny-server/

RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', port = as.numeric(Sys.getenv('PORT', unset = '3838')), host = '0.0.0.0')"]
