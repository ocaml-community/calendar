
all: build test

build:
	@dune build @install

clean:
	@dune clean

test:
	@exec dune runtest --no-buffer --force

doc:
	@dune build @doc

.PHONY: all clean test
