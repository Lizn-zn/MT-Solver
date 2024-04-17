(set-logic QF_NRA)
(set-info :smt-lib-version 2.0)
(declare-fun x1 () Real)
(declare-fun y1 () Real)
(declare-fun x2 () Real)
(declare-fun y2 () Real)
(declare-fun x3 () Real)
(declare-fun y3 () Real)
(declare-fun x4 () Real)
(declare-fun y4 () Real)
(assert (< (+ (- 63) (* x1 x1) (* x2 x2) (* x3 x3) (* x4 x4)) 0))
(assert (> (+ (- 64) (* y1 y1) (* y2 y2) (* y3 y3) (* y4 y4)) 0))
(assert (not (>= (+ (- (/ 1 1000000)) (* (+ (* (- 1) y1) x1) (+ (* (- 1) y1) x1)) (* (+ (* 
(- 1) y2) x2) (+ (* (- 1) y2) x2)) (* (+ (* (- 1) y3) x3) (+ (* (- 1) 
y3) x3)) (* (+ (* (- 1) y4) x4) (+ (* (- 1) y4) x4))) 0)))
(check-sat)
(get-model)
(exit)