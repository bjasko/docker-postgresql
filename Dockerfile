FROM ubuntu:14.04
MAINTAINER Jasmin Beganović <bjasko@bring.out.ba>
ENV PG_MAJOR 9.1

# pre-instalation requirements  
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN groupadd -r postgres && useradd -r -g postgres postgres
RUN alias adduser='useradd'  

# make the "bs_BA.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i bs_BA -c -f UTF-8 -A /usr/share/locale/locale.alias bs_BA.UTF-8 \
    && locale-gen bs_BA.UTF-8 \
    && update-locale LANG=bs_BA.UTF-8

# set the correct timezone
RUN echo "Europe/Sarajevo" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# apt-get psql + utils 
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common curl
RUN apt-get -y -q install postgresql-9.1 postgresql-client-9.1 postgresql-contrib-9.1
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# create psql cluster, import empty data structure 
USER postgres
RUN /etc/init.d/postgresql start \ 
    && psql --command "CREATE USER admin  WITH SUPERUSER PASSWORD 'xxxxxxxxx';" \ 
    && psql --command "CREATE ROLE  xtrole NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;" \
    && createdb -O admin empty \
    && createdb -O admin empty_sezona \
    && cd /tmp \
    && curl -O  http://download.bring.out.ba/empty_4.8.0_template.backup \
    && pg_restore -Fc -d empty empty_4.8.0_template.backup \
    && rm -rf empty_4.8.0_template.backup
  


# psql settings 
USER root
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PG_MAJOR/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PG_MAJOR/main/postgresql.conf

EXPOSE 5432
RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]


USER postgres
CMD ["/usr/lib/postgresql/9.1/bin/postgres", "-D", "/var/lib/postgresql/9.1/main", "-c", "config_file=/etc/postgresql/9.1/main/postgresql.conf"]


