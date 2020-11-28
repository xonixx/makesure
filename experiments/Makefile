
SHELL := /bin/bash

QJS_VERSION=2020-11-08
QJS_HOME=soft/quickjs-$(QJS_VERSION)

soft:
	mkdir soft

$(QJS_HOME)/qjsc: ../soft
	@echo "$$PATH" \
	echo "Fetching QJS..." \
	echo "" \
	cd "./soft" \
	QJS=quickjs-$QJS_VERSION \
	wget https://bellard.org/quickjs/${QJS}.tar.xz \
	tar xvf ./$QJS.tar.xz \
	rm ./$QJS.tar.xz \
	echo \
	echo "Compile QJSC..." \
	echo \
	cd "./$QJS" \
	make qjsc libquickjs.a libquickjs.lto.a

soft_qjsc: $(QJS_HOME)/qjsc

test:

just_build:

build: soft_qjsc just_build test