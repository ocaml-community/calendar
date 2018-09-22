
all: build test

build:
	@dune build @install

clean:
	@dune clean

test:
	@exec dune runtest --no-buffer --force

.PHONY: all clean test
