(* OCaml implementation of Wake-On-Lan 
 *
 * 2014-01-06
 * dRbiG
 *
 * Just dabblin' in.
 *)

open Unix

module StringMap = Map.Make (String)

let brdip = "192.168.0.255";;

let mactab =
  List.fold_left (fun m (k, v) ->
    StringMap.add k v m
  ) StringMap.empty [
    ("bebop.l", "70:5A:B6:94:8F:59");
    ("gamer.l", "00:25:22:f4:0b:0e");
    ("lore.l",  "00:40:ca:6d:16:07");
    ("nox.l",   "00:40:63:D5:8B:65");
    ("rpi.l",   "B8:27:EB:0D:EB:01")];;

let parse_mac = fun mac ->
  List.map (fun x -> int_of_string ("0x" ^ x)) (Str.split (Str.regexp ":") mac);;

let dup_list = fun lst times ->
  let lr = ref [] in
    for i = 1 to times do lr := !lr @ lst done;
    !lr;;

let make_payload = fun addr ->
  let payload = (dup_list [255] 6) @ (dup_list addr 16)
  and buf = String.create 102 in
    List.iteri (fun i x -> String.set buf i (char_of_int x)) payload;
    buf;;

let () =
  let sock = socket PF_INET SOCK_DGRAM 0
  and target = ADDR_INET(inet_addr_of_string brdip, 9) in
    setsockopt sock SO_BROADCAST true;
    for i = 1 to Array.length Sys.argv - 1 do
      let token = Sys.argv.(i) in
      let addr = try
        parse_mac @@
          try
            StringMap.find token mactab
          with Not_found ->
            token
      with _ -> [] in
        if List.length addr <> 6 then
          Printf.printf "%s: parse error!\n" token
        else
          let payload = make_payload addr in
            for x = 1 to 3 do
              ignore @@ sendto sock payload 0 (String.length payload) [MSG_PEEK] target
            done
    done;;
