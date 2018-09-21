
all: build test

build:
	@dune build @install

clean:
	@dune clean

test:
	@dune runtest

.PHONY: all clean test
