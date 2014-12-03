(* Simple cohttp client test harness *)
open Core.Std                                                                   
open Async.Std                                                                  
open Cohttp_async  

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
  let s_rp = Cohttp_async.Response.sexp_of_t rp
  and s_bd = Cohttp_async.Body.sexp_of_t body in
  print_endline "\n=== Response ===\n";
  print_endline (Sexp.to_string s_rp);
  print_endline "\n=== Body ===\n";
  print_endline (Sexp.to_string s_bd);
  return ()

  

let test_port_basic port qn qv =
  Printf.sprintf "Connecting port: %d" port |> log;
  let uri =
    match qn, qv with
    | Some n, Some v -> get_query_uri (Query (n, v)) port
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
      +> flag "-p" (required int) ~doc:"specify port number"
      +> flag "-qn" (optional string) ~doc:"query name"
      +> flag "-qv" (optional string) ~doc:"query value"
    )
    (fun port qn qv () -> test_port_basic port qn qv)
  |> Command.run

