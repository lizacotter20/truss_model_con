(defun drawtrussmodelcon (H H0 n a b insert chir / H0scale Hscale H0sqr Hsqr plusminus minusplus param twoparam x1 x2 denom c a phi1 phi0 p1b p2b p1t p2t pslt plt heightpt bar_radius numer)
	(defun *error* (msg)
		(if (= msg "Function cancelled")
			(progn
				(print "Function was canceled, exploding groups")
				(command "_ucs" "W")
				;(command-s "_ungroup" "NA" "panel_and_tab" "")
				;(command-s "_ungroup" "NA" "first_rot" "")
			)
			(progn
				(print "Error thrown, exploding groups")
				(command "_ucs" "W")
				;(command-s "_ungroup" "NA" "panel_and_tab" "")
				;(command-s "_ungroup" "NA" "first_rot" "")
			)
		)
	)

	;useful terms to clean up the calculations
	(setq H0sqr (expt H0 2))
	(setq Hsqr (expt H 2))
	(setq param (/ pi n))
	(setq twoparam (* 2 param))

	;radii of the two polygons
	(setq rsmall (/ a (* 2 (sin param))))
	(setq Rlarge (/ b (* 2 (sin param))))

	;more useful terms to clean up the calculations
	;(setq rssqr (expt rsmall 2))
	;(setq Rlsqr (expt Rlarge 2))

	;do the calculations for the Kresling
	(setq phi0 (- (acos (/ (- H0sqr Hsqr) (* (* (* 4 rsmall) Rlarge) (cos param)))) param)) ;phi0 is the twisting angle associated with the folded height (H0)
	(setq phi1 (- (- pi (/ (* 2 pi) n)) phi0))
	;(setq c (expt (- (+ H0sqr (+ rssqr Rlsqr)) (* (* (* 2 rsmall) Rlarge) (cos phi0))) 0.5))
	;(setq v (expt (- (+ H0sqr (+ rssqr Rlsqr)) (* (* (* 2 rsmall) Rlarge) (cos (+ phi0 (* 2 param))))) 0.5))
	;(setq beta (acos (/ (- (+ (expt b 2) (expt c 2)) (expt v 2)) (* (* 2 b) c))))

	;calculate node locations
	;bottom nodes
	(setq p1b (list (+ (* b (cos 0)) (car insert)) (+ (* b (sin 0)) (cadr insert)) 0))
	(setq p2b (list (+ (* b (cos twoparam)) (car insert)) (+ (* b (sin twoparam)) (cadr insert)) 0))

	;top nodes
	(setq p1t (list (+ (* a (cos (+ 0 phi1))) (car insert)) (+ (* a (sin (+ 0 phi1))) (cadr insert)) H))
	(setq p2t (list (+ (* a (cos (+ twoparam phi1))) (car insert)) (+ (* a (sin (+ twoparam phi1))) (cadr insert)) H))
	(setq pslt (list (+ (* a (cos (+ (* (- n 2) twoparam) phi1))) (car insert)) (+ (* a (sin (+ (* (- n 2) twoparam) phi1))) (cadr insert)) H))
	(setq plt (list (+ (* a (cos (+ (* (- n 1) twoparam) phi1))) (car insert)) (+ (* a (sin (+ (* (- n 1) twoparam) phi1))) (cadr insert)) H))

	;make the top and bottom plates 

	;the plates interfere with drawing the creases, so put in a layer and hide (later)
	(command "_layer" "_n" "platelay" "")
	(command "_layer" "_color" 4 "platelay" "")
	
	(makeplate insert b param n p1b p2b)
	(command "_change" (entlast) "" "_p" "_la" "platelay" "")
	(setq heightpt (list (car insert) (cadr insert) H))
	(makeplate heightpt a param n p1t p2t)
	(command "_change" (entlast) "" "_p" "_la" "platelay" "")

	(command "_layer" "off" "platelay" "")

	;make the mountains and valleys
	(setq bar_radius 0.03)
	(if (= chir "ccw")
		(progn
			(setq numer 1)

			;mountains
			(command "_cylinder" p1b bar_radius "A" p1t)
			(repeat (- n 1)
				(command "_copy" (entlast) "" "" "")
				(command "_rotate3d" (entlast) "" "z" insert (/ 360.0 n) "")
				(setq numer (+ 1 numer))
			)
			
			;valleys
			(command "_cylinder" p1b bar_radius "A" p2t)
			(repeat (- n 1)
				(command "_copy" (entlast) "" "" "")
				(command "_rotate3d" (entlast) "" "z" insert (/ 360.0 n) "")
				(setq numer (+ 1 numer))
			)		
		)
		(progn
			(setq numer 1)

			;mountains
			(command "_cylinder" p1b bar_radius "A" pslt)
			(repeat (- n 1)
				(command "_copy" (entlast) "" "" "")
				(command "_rotate3d" (entlast) "" "z" insert (/ 360.0 n) "")
				(setq numer (+ 1 numer))
			)
			
			;valleys
			(command "_cylinder" p1b bar_radius "A" plt)
			(repeat (- n 1)
				(command "_copy" (entlast) "" "" "")
				(command "_rotate3d" (entlast) "" "z" insert (/ 360.0 n) "")
				(setq numer (+ 1 numer))
			)
		)
	)
	(command "_layer" "on" "platelay" "")
	(print heightpt)
)	