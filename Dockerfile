FROM gcr.io/tensorflow/tensorflow:1.7.0-rc0-devel-gpu

RUN bazel version

RUN apt-get update && apt-get install -y \
    tmux \
    vim

CMD bash
