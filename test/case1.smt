(declare-fun b () Real)
(declare-fun a () Real)
(assert (= (+ (^ a 2.0) (^ b 2.0)) (* 2.0 a b)))
(assert (not (>= (+ (^ a 2.0) (^ b 6.0)) (* 2.0 (^ a 2.0) (^ b 3.0)))))
(check-sat)