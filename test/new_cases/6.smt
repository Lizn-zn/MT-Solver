(declare-const a Real)
(declare-const b Real)

(assert (not (= (+ (* a a) (* b b) (* 2 a b)) (* (+ a b) (+ a b)))))

(check-sat)
(get-model)