(declare-const c Real)
(declare-const a Real)
(declare-const b Real)
(assert (= (* (* a b) c) 1.0))
(assert (< 0.0 c))
(assert (< 0.0 b))
(assert (< 0.0 a))
(assert (distinct (- (/ 1.0 3.0) (/ (^ (+ (+ (^ (/ 1.0 (^ b 3)) (/ 1.0 3.0)) (^ (/ 1.0 (^ c 3)) (/ 1.0 3.0))) (^ (/ 1.0 (^ a 3)) (/ 1.0 3.0))) 3) (^ (+ (+ (* (+ (* 2.0 a) c) b) (* (+ a (* 2.0 b)) c)) (* (+ b (* 2.0 c)) a)) 2))) (/ (- (- (- (* (* (* 3.0 (^ a 3)) (^ b 3)) (^ c 3)) (* a b)) (* a c)) (* b c)) (* (* (* 9.0 (^ a 3)) (^ b 3)) (^ c 3)))))
(check-sat)
(get-model)