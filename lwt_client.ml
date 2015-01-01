open Lwt
open Core.Std

let localhost = "http://localhost:";;
let google = "http://www.google.com";;

let log s =
  let t = Time.now () in
  let msg = "[INFO] : " ^ (Time.to_string t) ^ " : " ^ s in
  prerr_endline msg

type query = string * string

type quries =
  | None
  | Query of query
  | Queries of query list

let add_query (s, v) = function
  | None -> Query (s, v)
  | Query (s', v') -> Queries [(s, v); (s', v')]
  | Queries qs -> Queries ((s, v) :: qs)

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

let print_header h =
  Printf.printf "[Header] : ";
  let iter_f k vs =
    Printf.printf "key: %s - value: " k;
    List.iter vs ~f:(fun v -> Printf.printf "%s " v);
    Printf.printf "\n"
  in Cohttp.Header.iter iter_f h; flush stdout

let test_port_basic port qn qv hn hv =
  Printf.sprintf "Connecting port: %d" port |> log;
  let uri =
    match qn, qv with
    | Some n, Some v -> begin
       let qns = String.split n ~on:','
       and qvs = String.split v ~on:',' in
       if List.length qns <> List.length qvs then
         failwith "Number of query names mismatches 
                   with number of query values"
       else begin
         let fold_f qs (s, v) = add_query (s, v) qs in
         let qs = List.fold_left (List.zip_exn qns qvs) ~init:(Queries []) 
          ~f:fold_f in
         get_query_uri qs port end
       end
    | None, None -> get_query_uri None port
    | _, _ -> failwith "Invalid arguments" in
  prerr_endline ("[Uri] : " ^ (Uri.to_string uri));
  let headers =
    match hn, hv with
    | Some n, Some v -> begin
       let headers = Cohttp.Header.init_with n v in
       print_header headers;
       Some headers end
    | None, None -> None
    | _ -> failwith "Invalid arguments" in
  Cohttp_lwt_unix.Client.get ?headers uri >>= 
   (fun (rp, body) -> return (print_result rp body))

let command = 
  Command.basic 
    ~summary:"Cohttp testing harness"
    Command.Spec.(
      empty
      +> flag "-p" (required int) ~doc:"int port number"
      +> flag "-qn" (optional string) ~doc:"string query name"
      +> flag "-qv" (optional string) ~doc:"string query value"
      +> flag "-hn" (optional string) ~doc:"string header name"
      +> flag "-hv" (optional string) ~doc:"string header value"
    )
    (fun port qn qv hn hv () -> 
      test_port_basic port qn qv hn hv |> Lwt_unix.run)

let () = Command.run ~version:"0.1.0" ~build_info:"Runhang Li" command

