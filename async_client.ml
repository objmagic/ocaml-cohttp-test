(* Simple cohttp client test harness *)
open Core.Std
open Async.Std

(* localhost *)
let lh = "http://localhost:";;
(* sanity *)
let google = "http://www.google.com";;

let log s =
  let t = Time.now () in
  let msg = "[INFO] " ^ (Time.to_string t) ^ " : " ^ s in
  print_endline msg


type query = string * string

type queries =
  | None
  | Query of query
  | Queries of query list

let get_query_uri qs port =
  let base_uri = Uri.of_string (lh ^ (string_of_int port)) in
  match qs with
  | None -> base_uri
  | Query (q, c) ->
     Uri.add_query_param base_uri (q, [c])
  | Queries qs ->
     let rec add_qs uri qs =
       match qs with
       | [] -> uri
       | (q, c) :: xs ->
          let new_uri = Uri.add_query_param uri (q, [c]) in
          add_qs new_uri xs
     in add_qs base_uri qs

let print_result rp body =
  let s_rp = Cohttp_async.Response.sexp_of_t rp in
  print_endline "\n=== Response ===\n";
  print_endline (Sexp.to_string s_rp);
  print_endline "\n=== Body ===\n";
  (Cohttp_async.Body.to_string body) >>= (fun s -> return (print_endline s))

let get_5512_uri port tv =
  let uri = get_query_uri ["key", "nano"; "tries", tv] port in
  Printf.sprintf ("Using URI: "%s"\n" (Uri.to_string uri));
  uri

let test_port_basic port qn qv =
  Printf.sprintf "Connecting port: %d" port |> log;
  let uri =
    match qn, qv with
    | Some n, Some v -> 
       if port = 5512 then get_5512_uri port v else
       get_query_uri (Query (n, v)) port
    | None, None -> get_query_uri None port
    | _, _ -> failwith "Invalud arguments"
  in
  Cohttp_async.Client.get uri >>= (fun (rp, body) ->
    print_result rp body
  )

let () =
  Command.async_basic
    ~summary:"Cohttp test harness"
    Command.Spec.(
      empty
      +> flag "-p" (required int) ~doc:"int port number"
      +> flag "-qn" (optional string) ~doc:"string query name"
      +> flag "-qv" (optional string) ~doc:"string query value"
    )
    (fun port qn qv () -> test_port_basic port qn qv)
  |> Command.run
