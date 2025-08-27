.PHONY: all build up down scan k6 score cdr propose
all: ; ./scripts/harsh.sh all
build: ; ./scripts/harsh.sh build
up: ; ./scripts/harsh.sh up
down: ; ./scripts/harsh.sh down
scan: ; ./scripts/harsh.sh scan
k6: ; ./scripts/harsh.sh k6
score: ; ./scripts/harsh.sh score
cdr: ; ./scripts/harsh.sh cdr
propose: ; ./scripts/harsh.sh propose
