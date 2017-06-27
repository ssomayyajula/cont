open Core.Std

(** The continuation monad *)
type ('a, 'r) t

(** Construct a CPS computation from a continuation-accepting function *)
val cont : (('a -> 'r) -> 'r) -> ('a, 'r) t

(** Run a CPS computation on a continuation *)
val run : ('a, 'r) t -> ('a -> 'r) -> 'r

(** Calls a function on the "current" continuation *)
val callcc : (('a -> ('b, 'r) t) -> ('a, 'r) t) -> ('a, 'r) t

include Monad.S2 with type ('a, 'r) t := ('a, 'r) t

module Thread : sig
  val yield : unit -> (unit, unit) t
  val exit : unit -> (unit, unit) t
  val fork : (unit -> ('a, unit) t) -> (unit, unit) t
end

