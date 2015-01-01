ocaml-cohttp-test
=================

HTTP Performance and Profiling Harness for Mirage's OCaml-cohttp.
This is one of the Mirage's [pioneer
projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects)

## Tests

### Test clients against bad servers

As discussed in issue [#206](https://github.com/mirage/ocaml-cohttp/issues/206), we
need to test cohttp clients against bad servers.
["Hamms"](https://github.com/kevinburke/hamms)
is a program written in Python that provides runnable examples of scenarios
with bad servers. In the follwing test, cohttp clients will try to
handle each bad server run by "hamms". Please refer to "hamms"
[documentation](https://github.com/kevinburke/hamms)
for detailed description of the mode of each port.

#### Test results

- [x] **port 5500**:

**expected behaviour**: Program raises exception indicating "connection refused"

````
Uncaught exception:

(Unix.Unix_error "Connection refused" connect "")
````

- [x] **port 5501**:

**expected behaviour**: Client received nothing

- [x] **port 5502**:

**expected behaviour**: Program raises exception indicating
"connection closed"

````
Uncaught exception:

(Failure "Client connection was closed")
````

- [x] **port 5503**:

**expected behaviour** : Program raises exception indicating that
server closes connection.

````
Uncaught exception:

(Failure "Client connection was closed")
````

- [x] **port 5504**:

**expected behaviour** : Program raises exception
indicating response is malformed.

````
Uncaught exception:

(Failure "Failed to read response: Malformed response version: foo")
````

- [x] **port 5505**:

**expected behaviour** : Program raises exception indicating response is malformed.

````
Uncaught exception:

(Failure "Failed to read response: Malformed response version: foo")
````

- [x] **port 5506**:

**not sure** : Nothing happened and client showed same behaviour as ``curl``

- [x] **port 5507**:

**not sure** : Nothing happened and client showed same behaviour as ``curl``

- [x] **port 5508**:

**expected behaviour**

````Bash
$ ./lwt_client.native -p 5508 -qn sleep -qv 1
$ ./lwt_client.native -p 5508 -qn sleep -qv 5
$ ./lwt_client.native -p 5508 -qn sleep -qv 10
````

- [x] **port 5509**:

**expected behaviour**

_However_, note that adversary server can send an extremely large
 status code that crashes client because ``int_of_string`` fails

````Bash
$ ./lwt_client.native -p 5509 -qn status -qv 200
$ ./lwt_client.native -p 5509 -qn status -qv 301
````

- [x] **port 5510**:

**Unexpected behaviour**: Client does not crash.
However, client should receive data of size 1MB,
rather than 3 indicated by ``Content-Length``.
The following is the output.

````Bash
$ ./lwt_client.native -p 5510
[INFO] 2014-12-31 10:52:38.831440-08:00 : Connecting port: 5510

----------------- Response -----------------

((encoding(Fixed 3))(headers((connection keep-alive)(content-length 3)(content-type text/plain)(server Hamms/1.3)))(version HTTP_1_1)(status OK)(flush false))

----------------- Body -----------------

aaa
````

- [x] **port 5511**:

**expected behaviour** : Tests include receiving cookie of various sizes, ranging from 0 to 99999. All tests passed.

- [x] **port 5512**:

**expected behaviour** : Try the following command three times and get OK at the third time.
The test passes.
````Bash
./lwt_client.native -p 5512 -qn key,tries -qv nano,3
````

- [x] **port 5513**:

**expected behaviour** : Try the following command and client reacts as expected. Test passes.

````Bash
./lwt_client.native -p 5513 -qn failrate -qv 0.1
````

- [x] **port 5514**:

**expected behaviour**: Server will now return content with
different type than that indicated in the request. Try the
following the command and we observe client parses server's
content according to the type indicated in server's header.
All contents are parsed without error.


````Bash
./lwt_client.native -p 5514 -hn accept -hv text/morse
./lwt_client.native -p 5514 -hn accept -hv application/json
````
- [x] **port 5515**:

**Unexpected behaviour**: Client simply hangs up.

- [ ] **port 5516**:

**Expected behaviour**: Since server closes partway, client
only receives partial data. For example:

````Bash
$ ./lwt_client.native -p 5516 -hn accept -hv application/json
[INFO] : 2014-12-31 16:56:44.523581-08:00 : Connecting port: 5516
[Uri] : http://localhost:5516
[Header] : key: accept - value: application/json

----------------- Response -----------------

((encoding(Fixed 2085))(headers((content-length 2085)(content-type application/json)))(version HTTP_1_1)(status OK)(flush false))

----------------- Body -----------------

{"message": "the json body is incomplete.", "key": {"nested_message": "blah blah blah
````

## License
GPL V3
