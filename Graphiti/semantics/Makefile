# Before using this, make sure ocamlbuild can find opam packages. 
# Therefore run the following command
# eval 'opam config env'

# To build this, just move the original files from Micro-C
# 1- parser.mly
# 2- scanner.mll
# 3- ast.ml

# the graphiti.ml used to "compile" the Scanner/Parser program
# more comments inside

# This program has test cases in the cases/ directory
# The test script runs the program with input being the language

.PHONY: all
all: graphiti.native graph.o 

graph.bc: graph.c
	clang -emit-llvm -o graph.bc -c graph.c -Wno-varargs

graphiti.native: graph.bc
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis,llvm.bitreader  -cflags -w,+a-3 graphiti.native

printbig.o: printbig.c
	cc -c printbig.c

# "make clean" removes all generated files
.PHONY: clean
clean:
	ocamlbuild -clean
	rm -rf testall.log *.diff graphiti scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o *.s *.ll *.out *.err *.exe *~
	rm -rf ./tests/*~
	rm -rf *.o
	rm -rf *.bc
	rm -rf *.output
