(prompt "\nType trussmodelcon to run.....")

(defun c:trussmodelcon ( / dcl_id flag p1 H H0 n a b)

	;flag is for discerning whether the dialog was canceled or hidden for starting point selection
	(setq flag 5)

	;load the dialog 
	(setq dcl_id (load_dialog "trussmodelcon.dcl"))

	;while the flag is not accept or cancel
	(while (> flag 2)
		;make a new dialog
		(if (not (new_dialog "trussmodelcon" dcl_id))
			(exit)
		)
		
		;set the values of the edit_boxes to their previous values, if there is one
		(if (= Hstrtruss nil)
			(action_tile "H" "(setq Hstrtruss $value)")
			(set_tile "H" Hstrtruss)
		)
		(if (= H0strtruss nil)
			(action_tile "H0" "(setq H0strtruss $value)")
			(set_tile "H0" H0strtruss)
		)
		(if (= nstrtruss nil)
			(action_tile "n" "(setq nstrtruss $value)")
			(set_tile "n" nstrtruss)
		)
		(if (= astrtruss nil)
			(action_tile "a" "(setq astrtruss $value)")
			(set_tile "a" astrtruss)
		)
		(if (= bstrtruss nil)
			(action_tile "b" "(setq bstrtruss $value)")
			(set_tile "b" bstrtruss)
		)
		(if (= xstrtruss nil)
			(progn
				(action_tile "x" "(setq xstrtruss $value)")
				(setq xstrtruss "0")
			)
			(set_tile "x" xstrtruss)
		)
		(if (= ystrtruss nil)
			(progn
				(action_tile "y" "(setq ystrtruss $value)")
				(setq ystrtruss "0")
			)
			(set_tile "y" ystrtruss)
		)
		;(if (= zstrtruss nil)
		;	(progn
		;		(action_tile "z" "(setq zstrtruss $value)")
		;		(setq zstrtruss "0")
		;	)
		;	(set_tile "z" zstrtruss)
		;)

		;update string values with the values in the boxes, if they've been changed
		(action_tile "H" "(setq Hstrtruss $value)")
		(action_tile "H0" "(setq H0strtruss $value)") 
		(action_tile "n" "(setq nstrtruss $value)")
		(action_tile "a" "(setq astrtruss $value)")
		(action_tile "b" "(setq bstrtruss $value)")
		(action_tile "x" "(setq xstrtruss $value)")
		(action_tile "y" "(setq ystrtruss $value)") 
		;(action_tile "z" "(setq zstrtruss $value)") 

		;set the insertion point to what is in the x and y boxes
		(setq insert (list (distof (get_tile "x")) (distof (get_tile "y")))) ;(distof (get_tile "z"))))

		;remember which radio button was chosen last time
		(cond
			((= chir_truss nil) (setq chir_truss "cw"))
			((= chir_truss "cw") (set_tile "cw" "1"))
			((= chir_truss "ccw") (set_tile "ccw" "1"))
		)

		;radio buttons
		(action_tile "cw" "(setq chir_truss \"cw\")")
		(action_tile "ccw" "(setq chir_truss \"ccw\")")

		;in order for the user to be able to press ok, make sure the design constrtrussaints are not violated and that the parameter types are correct
		(action_tile "accept" "(checktypestruss)")

		;set canceled to true if the dialog was canceled so we dont do unecessary calculations + drawings
		(action_tile "cancel" "(setq canceled T)")

		;flag to hide the dialog box is 5
		(action_tile "select_pt" "(done_dialog 5)")

		;set the flag to whatever start_dialog pulls from done_dialog
		(setq flag (start_dialog))

		;if the select point button was clicked 
		(if (= flag 5)
			;get the point from the user
			(progn
				(setq insert (getpoint))
				(setq xstrtruss (rtos (car insert)))
				(setq ystrtruss (rtos (cadr insert)))
				;(setq zstrtruss (rtos (caddr insert)))
			)
		)
	)

	(unload_dialog dcl_id)
	
	;if the dialog was canceled, don't draw anything, otherwise call the appropriate routine to do calculations and drawing
	(if canceled
		(setq canceled nil)
		(progn
			;convert string values to reals or ints
			(setq H (distof Hstrtruss))
			(setq H0 (distof H0strtruss))
			(setq n (atoi nstrtruss))
			(setq a (distof astrtruss))
			(setq b (distof bstrtruss))
		
			;get the latest point from the box
			(setq insert (list (distof xstrtruss) (distof ystrtruss))) ;(distof zstrtruss)))

			(print H)
			(print H0)
			(print n)
			(print a)
			(print b)
			(print insert)
			(print chir_truss)

			;call appropriate drawing routine based on crease pattern type
			(drawtrussmodel H H0 n a b insert chir_truss)
		)
	)
	(princ)
)