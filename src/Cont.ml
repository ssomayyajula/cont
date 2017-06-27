open Core.Std
open Fn

type ('a, 'r) t = ('a -> 'r) -> 'r

type ('a, 'b, 'r) cont = 'a -> ('b, 'r) t

let cont = id

let run = (@@)

let callcc f c = f (compose const c) c

include Monad.Make2 (struct
  type ('a, 'r) z = ('a, 'r) t
  
  type ('a, 'r) t = ('a, 'r) z
  
  let return = (|!)
  
  let bind m k c = m (flip k c)
  
  let map = `Define_using_bind
end)

module Thread (T : sig type r end) = struct
  (* Threads are unit -> r continuations *)
  
  (* The global queue of threads-to-be-executed *)
  let queue = Queue.create ()
  
  (* FIFO scheduling: execute the next thread in line *)
  let exit _ = Queue.dequeue_exn queue () 
  
  (* Interrupt the execution of the current thread to the given one *)
  let fork f = callcc
    (fun ct ->
       Queue.enqueue queue ct;
       f () >>= fun _ -> exit ())
  
  (* Yields execution to the next thread in line *)
  let yield () = callcc
    (fun ct ->
       Queue.enqueue queue ct;
       exit ())
  
  (* Runs a threaded computation *)
  let start = flip run id
end

let rec quicksort = function
| []     -> return []
| h :: t ->
    let (l, r) = List.partition_tf t ~f:((<=) h) in
    
    fork (fun _ -> quicksort l) >>= fun _  ->
    yield ()                    >>= fun _  ->
    fork (fun _ -> quicksort r) >>= fun _  ->
    yield ()                    >>= fun _  ->
    exit ()                     >>= fun l' ->
    exit ()                     >>= fun r''  ->
    return (l' @ [h] @ r')

(*
let counter = ref 100

let rec spew i =
  if !counter <= 0 then
    Thread.exit ()
  else begin
    Printf.printf "Thread %d signing on with %d to go\n" i (!counter);
    counter := !counter - 1;
    Thread.yield () >>= fun _ ->
    spew i
  end

let main = Thread.start begin
  Thread.fork(fun _ -> spew 1) >>= fun _ ->
  Thread.fork(fun _ -> spew 2) >>= fun _ ->
  Thread.fork(fun _ -> spew 3) >>= fun _ ->
  Thread.fork(fun _ -> spew 4) >>= fun _ ->
  Thread.exit ()
end
*)
