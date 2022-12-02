FROM hashicorp/terraform:latest
ENTRYPOINT ["/buddy/scale.sh"]
WORKDIR /buddy
ADD . /buddy
RUN chmod +x /buddy/scale.sh