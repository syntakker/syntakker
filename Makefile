all: test

build:
	ocamlbuild -use-ocamlfind -cflags -thread,-annot,-bin-annot begriffTest.native
	ocamlbuild -use-ocamlfind -cflags -thread,-annot,-bin-annot syntakker.docdir/index.html

test: build
	./begriffTest.native

clean:
	find . -name '_build' | xargs rm -rf
	find . -name '*.native' | xargs rm -f
	find . -name '*~' | xargs rm -f
	rm *.docdir

.PHONY: build test clean
