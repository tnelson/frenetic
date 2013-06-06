open OpenFlow0x01 (* TODO(arjun): fixup *)

open OxStart
open OxPlatform
open OpenFlow0x01_Core

(* Write a packet_in function that:
  
   1. Blocks all ICMP traffic
   2. Counts the number of HTTP packets (requests and responses to port 80)
   3. Repeats all non-ICMP traffic

   *Do not* write a flow table.
 *)
module MyApplication : OXMODULE = struct

  include DefaultTutorialHandlers

  let num_http_packets = ref 0

  let switch_connected (sw : switchId) : unit = 
    Printf.printf "Switch %Ld connected.\n%!" sw
      
  (* [FILL IN HERE]: write this predicate *)
  let is_http_packet (pk : Packet.packet) : bool = 
    Packet.dlTyp pk = 0x800 &&
    Packet.nwProto pk = 6 &&
    (Packet.tpSrc pk = 80 || Packet.tpDst pk = 80)

  (* [FILL IN HERE] You can use the packet_in function from OxTutorial2. *)
  let packet_in (sw : switchId) (xid : xid) (pktIn : packetIn) : unit =
    if is_http_packet (parse_payload pktIn.input_payload) then
      begin
        num_http_packets := !num_http_packets + 1;
        Printf.printf "Seen %d HTTP packets.\n%!" !num_http_packets
      end;
    (* [FILL IN HERE] Use the packet_in function from OxTutorial2 here. *)
    let payload = pktIn.input_payload in
    let pk = parse_payload payload in
    if Packet.dlTyp pk = 0x800 && Packet.nwProto pk = 1 then
      send_packet_out sw 0l
        { output_payload = payload;
          port_id = None;
          apply_actions = []
        }
    else 
      send_packet_out sw 0l
        { output_payload = payload;
          port_id = None;
          apply_actions = [Output AllPorts]
        }

  let port_status (sw : switchId) (xid : xid) (port : PortStatus.t) : unit =
    ()

end

module Controller = Make (MyApplication)