FROM hashicorp/terraform:latest
ENTRYPOINT ["/buddy/scale.sh"]
WORKDIR /buddy
RUN chmod +x /buddy/scale.sh
ADD . /buddy