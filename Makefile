

all: check rpm

check:
	fpb --check .

rpm:
	fpb --build .

