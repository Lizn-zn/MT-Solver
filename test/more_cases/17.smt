(declare-const b Real)
(declare-const c Real)
(declare-const a Real)
(assert (>= (* (* a b) c) (/ 1 (* 3 (^ 3 (/ 1 3))))))
(assert (= (+ (+ (* a b) (* b c)) (* c a)) 1))
(assert (> c 0))
(assert (> b 0))
(assert (> a 0))
(assert (not (<= (+ (* (* (* c a) b) (+ (+ (^ (+ (* 6 a) (/ 1 c)) (/ 1 3)) (^ (+ (* 6 b) (/ 1 a)) (/ 1 3))) (^ (+ (* 6 c) (/ 1 b)) (/ 1 3)))) (- 1)) 0)))
(check-sat)
(get-model)
(exit)