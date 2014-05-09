all: test

build:
	ocamlbuild -use-ocamlfind -cflags -annot,-bin-annot begriffTest.native

test: build
	./begriffTest.native

clean:
	find . -name '_build' | xargs rm -rf
	find . -name '*.native' | xargs rm -f
	find . -name '*~' | xargs rm -f

.PHONY: build test clean
