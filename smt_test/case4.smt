(define-fun f ((x Real)) Real (^ (+ (+ (* (- 10) (^ x 2)) (- (* 11 x))) 6) (div 1 2)))
(assert (not (forall ((x Real)) (= (and (<= (/ (- 3) 2) x) (<= x (/ 2 5))) (<= 0 (+ (+ (* (- 10) (^ x 2)) (- (* 11 x))) 6))))))
(check-sat)
(get-model)