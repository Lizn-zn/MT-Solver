(define-fun is_in_interval ((x Real)) Bool (and (> x 2) (< x 6)))
(declare-const x Real)
(assert (not (=> (< (+ (+ (^ x 2) (- (* 7 x))) 6) 0) (is_in_interval x))))
(check-sat)