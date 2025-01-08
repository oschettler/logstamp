#
logstamp: src/logstamp.nim
	nim c -o:logstamp src/logstamp.nim

clean:
	rm -f logstamp

install: logstamp
	cp logstamp $(HOME)/bin

.PHONY: clean install