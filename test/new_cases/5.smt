(declare-const a Real)
(declare-const b Real)
(declare-const c Real)
(assert (> a 0))
(assert (> b 0))
(assert (> c 0))
(assert (= (+ a b c) 3))
(assert (> (* (pow 3 (/ 1 2)) (+ (* (/ 1 3) a) (* (/ 1 3) b) (* (/ 1 3) c))) (+ (pow (+ (pow a 2) (pow b 2) (* a b)) (/ 1 2)) (pow (+ (pow b 2) (pow c 2) (* b c)) (/ 1 2)) (* (/ 1 3) (pow 3 (/ 1 2)) (+ (pow (pow a 2) (/ 1 2)) (pow (pow c 2) (/ 1 2)) (pow (* a c) (/ 1 2)))))))
(check-sat)
(get-model)
(exit)