(set-logic QF_NRA)
(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (not (<= (* 27 (/ 1 (* 2 (^ (+ a b c) 2)))) (+ (* 1 (/ 1 (* a (+ b c)))) (* 1 (/ 1 (* b (+ c a)))) (* 1 (/ 1 (* c (+ a b))))))))
(check-sat)
(get-model)
(exit)