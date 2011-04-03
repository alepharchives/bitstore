COUCHDB=../couchdb


all: deps compile

compile:
	./rebar compile

deps:
	./rebar get-deps

clean: 
	./rebar clean

distclean: clean
	./rebar delete-deps
	rm ebin/*.tab

trigrams: src/354984si.ngl.gz ebin/indexer_trigrams.beam
	erl -pa ebin -noshell -s indexer_trigrams make_tables\
                                        -s init stop

config: trigrams
	cp config/couch.ini $(COUCHDB)/etc/couchdb/local_dev.ini

run: config
	ERL_FLAGS="-sname couch -pa ebin -pa deps/bitcask/ebin -pa deps/bitcask/deps/ebloom/ebin" $(COUCHDB)/utils/run -i



