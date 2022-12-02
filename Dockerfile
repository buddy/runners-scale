FROM hashicorp/terraform:latest
ENTRYPOINT ["/bin/sh"]
WORKDIR /buddy
ADD . /buddy
RUN chmod +x /buddy/scale.sh
ENTRYPOINT ["/buddy/scale.sh"]