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

let test_port_basic port =
  Printf.sprintf "Connecting port: %d" port |> log;
  let uri = get_query_uri None port in
  Cohttp_async.Client.get uri >>= (fun (rp, body) ->
    let s_bd = Cohttp_async.Response.sexp_of_t rp
    and s_rp = Cohttp_async.Body.sexp_of_t body in
    print_endline "\n=== Response===\n";
    print_endline (Sexp.to_string s_rp);
    print_endline "\n=== Body ===\n";
    print_endline (Sexp.to_string s_bd);
    return ()
  )

let () = 
  Command.async_basic 
    ~summary:"Cohttp test harness"
    Command.Spec.(
      empty +> anon ("port" %: int)
    )
    (fun port () -> test_port_basic port)
  |> Command.run

