open Cont

let calcLength (l : 'a list) : (int, 'r) t = return (List.length l)

let double (n : int) : (int, 'r) t = return (n * 2)

let main = run (calcLength [1;2;3] >>= double) print_int

