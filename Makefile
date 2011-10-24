CXX=g++
CXX_FLAGS=-O2 -Wall -ansi -pedantic-errors

COMMANDS=bin/unf bin/unf-test bin/unf-time bin/gen-unf-table
SRC=src/unf
BUILD_TRIES=${SRC}/trie/builder.hh ${SRC}/trie/char_stream.hh ${SRC}/trie/node_allocator.hh ${SRC}/trie/node.hh
SEARCH_TRIES=${SRC}/trie/char_stream.hh ${SRC}/trie/node.hh ${SRC}/trie/searcher.hh

UCD_URL=http://www.unicode.org/Public/5.2.0/ucd/

all: bin ${COMMANDS}

bin:
	mkdir bin

bin/gen-unf-table: ${SRC}/gen-unf-table.cc ${BUILD_TRIES}
	${CXX} ${CXX_FLAGS} -o ${@} ${<}

bin/unf: ${SRC}/unf.cc ${SRC}/normalizer.hh ${SRC}/table.hh ${SRC}/util.hh ${SEARCH_TRIES}
	${CXX} ${CXX_FLAGS} -o ${@} ${<}

bin/unf-test: ${SRC}/unf-test.cc ${SRC}/normalizer.hh ${SRC}/table.hh ${SRC}/util.hh ${SEARCH_TRIES}
	${CXX} ${CXX_FLAGS} -o ${@} ${<}

bin/unf-time: ${SRC}/unf-time.cc ${SRC}/normalizer.hh ${SRC}/table.hh ${SRC}/util.hh ${SEARCH_TRIES}
	${CXX} ${CXX_FLAGS} -o ${@} ${<}

clean:
	rm -f ${COMMANDS}

test: bin/unf-test
	${<} < data/normalization-test.txt

gen-table: bin/gen-unf-table
	bin/gen-unf-table ${SRC}/table.hh data

data/canonical-combining-class.def: \
		lisp/CompositionExclusions.txt \
		lisp/DerivedNormalizationProps.txt \
		lisp/UnicodeData.txt \
		lisp/gendef.lisp \
		lisp/unf.lisp
	@cd lisp; sbcl --noinform --eval '(progn (load "gendef.lisp") (generate-definition-files "../data") (quit))'

fetch-ucd:
	@cd lisp; curl -O ${UCD_URL}CompositionExclusions.txt
	@cd lisp; curl -O ${UCD_URL}DerivedNormalizationProps.txt
	@cd lisp; curl -O ${UCD_URL}UnicodeData.txt

gendef: data/canonical-combining-class.def
