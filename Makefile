all: test

build:
	ocamlbuild -use-ocamlfind -cflags -annot,-bin-annot firstTest.native

test: build
	./firstTest.native

.PHONY: all
