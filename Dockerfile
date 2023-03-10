FROM ubuntu:18.04
MAINTAINER BiomeHub

LABEL version="1.14.5"
LABEL software.version="1.14.5"
LABEL software="Prokka"


WORKDIR /NGStools/

# Dependencies
RUN apt-get update && \
    apt-get upgrade -y perl && \
    apt-get install -y parallel make wget git locales && \
    locale-gen --purge en_US.UTF-8 && \
    DEBIAN_FRONTEND="noninteractive" dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
RUN apt-get install -y python python-pip && \
    pip install setuptools

# Barrnap
RUN wget https://github.com/tseemann/barrnap/archive/0.9.tar.gz && \
    tar xf 0.9.tar.gz && \
    rm 0.9.tar.gz

# Infernal
RUN wget http://eddylab.org/infernal/infernal-1.1.2-linux-intel-gcc.tar.gz && \
    tar xf infernal-1.1.2-linux-intel-gcc.tar.gz && \
    rm infernal-1.1.2-linux-intel-gcc.tar.gz && \
    cd infernal-1.1.2-linux-intel-gcc && \
    ./configure && \
    make && \
    make install && \
    cd easel && \
    make install && \
    cd /NGStools && \
    rm -rf infernal-1.1.2-linux-intel-gcc/

# GenomeTools
RUN apt-get install -y libpango1.0-dev && \
    wget http://genometools.org/pub/genometools-1.5.10.tar.gz && \
    tar xf genometools-1.5.10.tar.gz && \
    rm genometools-1.5.10.tar.gz && \
    cd genometools-1.5.10 && \
    make && \
    make install && \
    cd gtpython && \
    python setup.py install && \
    cd /NGStools && \
    rm -rf genometools-1.5.10/

# gff3toembl
RUN mkdir gff3toembl && \
    cd gff3toembl && \
    git clone https://github.com/sanger-pathogens/gff3toembl.git && \
    python gff3toembl/setup.py install && \
    cd /NGStools

# Blast+
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.9.0/ncbi-blast-2.9.0+-x64-linux.tar.gz && \
    tar xf ncbi-blast-2.9.0+-x64-linux.tar.gz && \
    rm ncbi-blast-2.9.0+-x64-linux.tar.gz

# CD-HIT
RUN wget https://github.com/weizhongli/cdhit/releases/download/V4.6.8/cd-hit-v4.6.8-2017-0621-source.tar.gz && \
    tar xf cd-hit-v4.6.8-2017-0621-source.tar.gz && \
    rm cd-hit-v4.6.8-2017-0621-source.tar.gz && \
    cd cd-hit-v4.6.8-2017-0621 && \
    make && \
    cd cd-hit-auxtools && \
    make && \
    cd /NGStools

# Exonerate
RUN wget http://ftp.ebi.ac.uk/pub/software/vertebrategenomics/exonerate/exonerate-2.2.0-x86_64.tar.gz && \
    tar xf exonerate-2.2.0-x86_64.tar.gz --no-same-owner && \
    chmod 755 exonerate-2.2.0-x86_64/ && \
    rm exonerate-2.2.0-x86_64.tar.gz

ENV PATH="/NGStools/barrnap-0.9/bin:/NGStools/gff3toembl/gff3toembl/scripts:/NGStools/ncbi-blast-2.9.0+/bin:/NGStools/cd-hit-v4.6.8-2017-0621:/NGStools/cd-hit-v4.6.8-2017-0621/cd-hit-auxtools:/NGStools/exonerate-2.2.0-x86_64/bin:${PATH}" LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" PYTHONPATH="/NGStools/gff3toembl/gff3toembl:$PYTHONPATH"

# Prokka
RUN apt-get install -y libdatetime-perl libxml-simple-perl libdigest-md5-perl default-jre bioperl
# fix https://github.com/tseemann/prokka/issues/414
RUN cpan List::Util && \
    git clone https://github.com/tseemann/prokka.git && \
    prokka/bin/prokka --setupdb

# tbl2asn - new version fixes expiration date error
RUN wget ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux64.tbl2asn.gz && \
    gunzip linux64.tbl2asn.gz && \
    mv linux64.tbl2asn tbl2asn && \
    chmod +x tbl2asn && \
    mv tbl2asn /NGStools/prokka/binaries/linux/

# Sequin not install because it requires X Windows
# Be aware that EMBL validator changed. Please see http://www.ebi.ac.uk/ena/software/flat-file-validator for further information

ENV PATH="/NGStools/prokka/bin:${PATH}"

# Clean
RUN pip uninstall -y setuptools && apt-get remove -y git python-pip locales && apt-get autoclean -y

WORKDIR /data/