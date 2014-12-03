.PHONY: build clean
PKG=async,cohttp.async

build: 
	corebuild test_client.native -pkg $(PKG)

clean: 
	corebuild -clean
