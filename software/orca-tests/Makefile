TEST_DIRS := $(shell find -mindepth 2 -name 'Makefile' | xargs -n 1 dirname | xargs -n 1 basename)

all:
	for test_dir in $(TEST_DIRS); do make -C $$test_dir || exit 1; done

clean:
	find -mindepth 2 -name 'Makefile' -execdir make clean \;
	rm -f *~ \#*
