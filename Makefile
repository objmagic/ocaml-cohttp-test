.PHONY: build clean
PKG_ASYNC=async,cohttp.async
PKG_LWT=lwt.unix,lwt.syntax,cohttp.lwt

build-async:
	corebuild async_client.native -pkg $(PKG_ASYNC)

build-lwt:
	corebuild lwt_client.native -pkg $(PKG_LWT)

clean: 
	corebuild -clean
