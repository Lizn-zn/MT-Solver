(set-logic QF_NRAT)
(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (not (<= 1 (+ (* a (/ 1 (sqrt (+ (^ a 2) (* 8 b c))))) (* b (/ 1 (sqrt (+ (^ b 2) (* 8 a c))))) (* c (/ 1 (sqrt (+ (^ c 2) (* 8 a b)))))))))
(check-sat)
(get-model)
(exit)