# runstat Makefile

SWIFT_FLAGS = -O
BINARY_NAME = runstat
APP_NAME = runstat.app
INSTALL_PATH = /Applications

.PHONY: all build clean install uninstall

all: build

build:
	swiftc $(SWIFT_FLAGS) -o $(BINARY_NAME) runstat.swift

clean:
	rm -f $(BINARY_NAME)
	rm -rf $(APP_NAME)

install: build
	./install.sh

uninstall:
	rm -rf "$(INSTALL_PATH)/$(APP_NAME)"

.DEFAULT_GOAL := build
