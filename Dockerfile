FROM ubuntu:22.04
WORKDIR /buddy
ENTRYPOINT ["/buddy/calc.sh"]
ADD . /buddy
RUN chmod +x /buddy/calc.sh
