(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (not (<= 1 (+ (* a (pow (pow (+ (pow a 2) (* 8 b c)) (/ 1 2)) -1)) (* b (pow (pow (+ (pow b 2) (* 8 a c)) (/ 1 2)) -1)) (* c (pow (pow (+ (pow c 2) (* 8 a b)) (/ 1 2)) -1))))))
(check-sat)
(get-model)
(exit)