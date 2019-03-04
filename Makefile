ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: awesom.image test

Pharo.image:
	curl https://get.pharo.org/64/70 | bash

pharo:
	curl https://get.pharo.org/64/vm70 | bash

awesom.image: Pharo.image pharo
	./pharo ./Pharo.image save awesom
	./pharo awesom.image metacello install gitlocal://$(ROOT_DIR)/src BaselineOfAweSOM

som: awesom.image

test:
	./pharo awesom.image test AweSOM