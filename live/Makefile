INSTALL_PATH = /usr/local/bin/hublive

install:
	swift build -c release -Xswiftc -static-stdlib
	cp -f .build/release/hublive $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)
