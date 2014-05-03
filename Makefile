all: test

build:
	ocamlbuild -use-ocamlfind -cflags -annot,-bin-annot firstTest.native

test: build
	./firstTest.native

clean:
	rm *.native
	rm *~
	rm -rf _build

.PHONY: all
