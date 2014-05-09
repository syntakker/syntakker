all: test

build:
	ocamlbuild -use-ocamlfind -cflags -annot,-bin-annot firstTest.native

test: build
	./firstTest.native

clean:
	find . -name '_build' | xargs rm -rf
	find . -name '*.native' | xargs rm -f
	find . -name '*~' | xargs rm -f

.PHONY: all
