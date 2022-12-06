FROM ubuntu:22.04
WORKDIR /buddy
ADD . /buddy
RUN chmod +x /buddy/calc.sh
CMD ["/buddy/calc.sh"]