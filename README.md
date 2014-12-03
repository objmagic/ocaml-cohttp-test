ocaml-cohttp-test
=================

HTTP Performance and Profiling Harness for Mirage's OCaml-cohttp.
This is one of the Mirage's [pioneer projects](https://github.com/mirage/mirage-www/wiki/Pioneer-Projects)

## Tests

### Test clients against bad servers

As discussed in issue [#206](https://github.com/mirage/ocaml-cohttp/issues/206), we
need to test cohttp clients against bad servers. ["Hamms"](https://github.com/kevinburke/hamms)
is a program written in Python that provides runnable examples of scenarios
with bad servers. In the follwing test, cohttp clients will try to
handle each bad server run by "hamms". Please refer to "hamms" [documentation](https://github.com/kevinburke/hamms)
for detailed description of the mode of each port.

#### Test results

- [x] port 5500:

Async monitor raises exception, indicating "connection refused", which may be the right behavior.

````OCaml
[INFO] 2014-12-03 00:39:10.534164-08:00 : Connecting port: 5500
((pid 89027) (thread_id 0) (2014-12-03 00:39:10.538222-08:00)
 "unhandled exception in Async scheduler"
 ("unhandled exception"
  ((lib/monitor.ml.Error_
    ((exn (Unix.Unix_error "Connection refused" connect 127.0.0.1:5500))
     (backtrace
      ("Raised by primitive operation at file \"lib/unix_syscalls.ml\", line 851, characters 12-69"
       "Called from file \"lib/deferred.ml\", line 12, characters 64-67"
       "Called from file \"lib/jobs.ml\", line 214, characters 10-13" ""))
     (monitor
      (((name Tcp.close_sock_on_error) (here ()) (id 9) (has_seen_error true)
        (is_detached true) (kill_index 0))))))
   (Pid 89027))))
````

- [x] port 5501:

Client hangs up without receiving anything, which may be the expected result.

````OCaml
[INFO] 2014-12-03 00:41:33.289342-08:00 : Connecting port: 5501
````

- [x] port 5502:

Async monitor raises exception, indicating that server closes connection.
This should be the expected behaviour.

````OCaml
   [INFO] 2014-12-03 00:43:27.979641-08:00 : Connecting port: 5502
((pid 89839) (thread_id 0) (2014-12-03 00:43:27.988592-08:00)
 "unhandled exception in Async scheduler"
 ("unhandled exception"
  ((lib/monitor.ml.Error_
    ((exn (Failure "Connection closed by remote host"))
     (backtrace
      ("Raised at file \"async/cohttp_async.ml\", line 184, characters 21-63"
       "Called from file \"lib/deferred.ml\", line 12, characters 64-67"
       "Called from file \"lib/jobs.ml\", line 214, characters 10-13" ""))
     (monitor
      (((name main) (here ()) (id 1) (has_seen_error true)
        (is_detached false) (kill_index 0))))))
   (Pid 89839))))
````

- [x] port 5503:

Async monitor raises exception, indicating that
server closes connection. This may **not** be expected.

````OCaml
  [INFO] 2014-12-03 00:48:27.179752-08:00 : Connecting port: 5503
((pid 90741) (thread_id 0) (2014-12-03 00:48:27.190862-08:00)
 "unhandled exception in Async scheduler"
 ("unhandled exception"
  ((lib/monitor.ml.Error_
    ((exn (Failure "Connection closed by remote host"))
     (backtrace
      ("Raised at file \"async/cohttp_async.ml\", line 184, characters 21-63"
       "Called from file \"lib/deferred.ml\", line 12, characters 64-67"
       "Called from file \"lib/jobs.ml\", line 214, characters 10-13" ""))
     (monitor
      (((name main) (here ()) (id 1) (has_seen_error true)
        (is_detached false) (kill_index 0))))))
   (Pid 90741))))
````

- [x] port 5504:

Async monitor raise exception, indicating response is malformed.
This should be the expected result.

````OCaml
[INFO] 2014-12-03 09:57:16.105986-08:00 : Connecting port: 5504
((pid 99225) (thread_id 0) (2014-12-03 09:57:16.125056-08:00)
 "unhandled exception in Async scheduler"
 ("unhandled exception"
  ((lib/monitor.ml.Error_
    ((exn (Failure "Malformed response version: foo"))
     (backtrace
      ("Raised at file \"async/cohttp_async.ml\", line 185, characters 32-46"
       "Called from file \"lib/deferred.ml\", line 12, characters 64-67"
       "Called from file \"lib/jobs.ml\", line 214, characters 10-13" ""))
     (monitor
      (((name main) (here ()) (id 1) (has_seen_error true)
        (is_detached false) (kill_index 0))))))
   (Pid 99225))))
````

- [x] port 5505:

Same result as above

- [ ] port 5506:
- [ ] port 5507:
- [x] port 5508:

The following tests are sleeping 1 sec, 5 secs, and 10 secs , respectively. They all showed expected behaviour.
````Bash
$ ./test_client.native -p 5508 -qn sleep -qv 1
$ ./test_client.native -p 5508 -qn sleep -qv 5
$ ./test_client.native -p 5508 -qn sleep -qv 10
````


## License
WTFPL
