(declare-const c Real)
(assert (> c 0))
(declare-const b Real)
(assert (> b 0))
(declare-const a Real)
(assert (> a 0))
(assert (not (<= (+ (+ (/ (* 3 (^ c 2)) 2) (/ (* 3 (^ b 2)) 2)) (/ (* 3 (^ a 2)) 2)) (+ (+ (+ (* 5 (sqrt (/ (^ (+ (+ (^ (^ a 3) (/ 2 3)) (^ (^ b 3) (/ 2 3))) (^ (^ c 3) (/ 2 3))) 3) (+ (+ (^ (+ a (* 3 c)) 2) (^ (+ b (* 3 a)) 2)) (^ (+ c (* 3 b)) 2))))) (/ (^ a 3) (+ b (* 3 a)))) (/ (^ b 3) (+ c (* 3 b)))) (/ (^ c 3) (+ a (* 3 c)))))))
(check-sat)
(get-model)