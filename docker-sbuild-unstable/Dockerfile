FROM debian:stable

ADD prepare.sh .
ADD buildpackage.py.patch .
ADD prepare_subchroot.sh .

RUN sh prepare.sh
