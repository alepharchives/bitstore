.SUFFIXES: .erl .beam

.erl.beam:
	erlc -I include -o ebin -W +debug_info -DTEST $<

MODS = src/ontylog/dag\
       src/ontylog/bitstore\
       src/search/indexer_checkpoint\
       src/search/indexer_porter\
       src/search/indexer_words\
       src/search/indexer_couchdb_crawler\
       src/search/indexer_server\
       src/search/indexer\
       src/search/indexer_misc\
       src/search/indexer_trigrams

ERL = erl -boot start_clean

compile: ${MODS:%=%.beam} trigramsS.tab
	@echo "make clean - clean up"

all: compile 

trigramsS.tab: src/search/354984si.ngl.gz ebin/indexer_trigrams.beam
	@erl -pa ebin -noshell -s indexer_trigrams make_tables\
                                        -s init stop


clean:	
	rm -rf ebin/* erl_crash.dump 

