(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (= (+ a b c) 3))
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (not (= 0 (+ 0 (* -1 (+ 4 (* -1 (* 4 a (pow 3 -1))) (* -1 (* 4 b (pow 3 -1))) (* -1 (* 4 c (pow 3 -1)))))))))
(check-sat)
(get-model)
(exit)