(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (<= 3 (+ a b c)))
(assert (= (+ a b c) (+ (* 1 (pow a -1)) (* 1 (pow b -1)) (* 1 (pow c -1)))))
(assert (not (<= (+ (* 1 (pow (pow (+ (* 2 a) b c) 2) -1)) (* 1 (pow (pow (+ a (* 2 b) c) 2) -1)) (* 1 (pow (pow (+ a b (* 2 c)) 2) -1))) (* 3 (pow 16 -1)))))
(check-sat)
(get-model)
(exit)