(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (not (<= (+ (* (/ 1 3) (pow (+ (pow a 3) (pow b 3) (pow c 3)) (/ 1 3))) (* -1 (pow (* 2 (pow 2 c) (+ a b) (+ a b c)) (pow (+ 2 c) -1)) (+ 2 c)) (* 8 (pow a (/ 1 3)) (pow b (/ 1 3)) (pow c (/ 1 3)))) 0)))
(check-sat)
(get-model)
(exit)