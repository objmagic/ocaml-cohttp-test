open Lwt
open Core.Std

let localhost = "http://localhost:";;
let google = "http://www.google.com";;

let log s =
  let t = Time.now () in
  let msg = "[INFO] " ^ (Time.to_string t) ^ " : " ^ s in
  prerr_endline msg

type query = string * string

type quries =
  | None
  | Query of query
  | Queries of query list

let get_query_uri qs port =
  let base_uri = Uri.of_string (localhost ^ (string_of_int port)) in
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
  let sexp_of_rp = Cohttp_lwt_unix.Response.sexp_of_t rp 
  and string_of_body = Lwt_unix.run (Cohttp_lwt_body.to_string body) in
  prerr_endline "\n----------------- Response -----------------\n";
  prerr_endline (Sexp.to_string sexp_of_rp);
  prerr_endline "\n----------------- Body -----------------\n";
  prerr_endline string_of_body


let get_5512_uri port tv =
  let uri = get_query_uri (Query ("key", "nano")) port in
  let uri = Uri.add_query_param uri ("tries", [tv]) in
  prerr_endline (Uri.to_string uri);
  uri

let test_port_basic port qn qv =
  Printf.sprintf "Connecting port: %d" port |> log;
  let uri =
    match qn, qv with
    | Some n, Some v ->
       if port = 5512 then get_5512_uri port v else
         get_query_uri (Query (n, v)) port
    | None, None -> get_query_uri None port
    | _, _ -> failwith "Invalid arguments"
  in
  Cohttp_lwt_unix.Client.get uri >>= (fun (rp, body) ->
    return (print_result rp body))

let command = 
  Command.basic 
    ~summary:"Cohttp testing harness"
    Command.Spec.(
      empty
      +> flag "-p" (required int) ~doc:"int port number"
      +> flag "-qn" (optional string) ~doc:"string query name"
      +> flag "-qv" (optional string) ~doc:"string query value"
    )
    (fun port qn qv () -> test_port_basic port qn qv |> Lwt_unix.run)

let () = Command.run ~version:"0.1.0" ~build_info:"Runhang Li" command

