(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (>= (* (* a b) c) (/ 1 (* 3 (^ 3 (/ 1 3))))))
(assert (< 0 a))
(assert (< 0 b))
(assert (< 0 c))
(assert (= (+ (* a b) (* a c) (* b c)) 1))
(assert (not (<= (+ (* 3 (pow (+ (* 2 a) (* 2 b) (* 2 c) (* (/ 1 3) (pow a -1)) (* (/ 1 3) (pow b -1)) (* (/ 1 3) (pow c -1))) (/ 1 3))) (* -1 (pow a -1) (pow b -1) (pow c -1))) 0)))
(check-sat)
(get-model)
(exit)