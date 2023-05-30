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
		(if (= Hstrtrusscon nil)
			(action_tile "H" "(setq Hstrtrusscon $value)")
			(set_tile "H" Hstrtrusscon)
		)
		(if (= H0strtrusscon nil)
			(action_tile "H0" "(setq H0strtrusscon $value)")
			(set_tile "H0" H0strtrusscon)
		)
		(if (= nstrtrusscon nil)
			(action_tile "n" "(setq nstrtrusscon $value)")
			(set_tile "n" nstrtrusscon)
		)
		(if (= astrtrusscon nil)
			(action_tile "a" "(setq astrtrusscon $value)")
			(set_tile "a" astrtrusscon)
		)
		(if (= bstrtrusscon nil)
			(action_tile "b" "(setq bstrtrusscon $value)")
			(set_tile "b" bstrtrusscon)
		)
		(if (= xstrtrusscon nil)
			(progn
				(action_tile "x" "(setq xstrtrusscon $value)")
				(setq xstrtrusscon "0")
			)
			(set_tile "x" xstrtrusscon)
		)
		(if (= ystrtrusscon nil)
			(progn
				(action_tile "y" "(setq ystrtrusscon $value)")
				(setq ystrtrusscon "0")
			)
			(set_tile "y" ystrtrusscon)
		)
		;(if (= zstrtrusscon nil)
		;	(progn
		;		(action_tile "z" "(setq zstrtrusscon $value)")
		;		(setq zstrtrusscon "0")
		;	)
		;	(set_tile "z" zstrtrusscon)
		;)

		;update string values with the values in the boxes, if they've been changed
		(action_tile "H" "(setq Hstrtrusscon $value)")
		(action_tile "H0" "(setq H0strtrusscon $value)") 
		(action_tile "n" "(setq nstrtrusscon $value)")
		(action_tile "a" "(setq astrtrusscon $value)")
		(action_tile "b" "(setq bstrtrusscon $value)")
		(action_tile "x" "(setq xstrtrusscon $value)")
		(action_tile "y" "(setq ystrtrusscon $value)") 
		;(action_tile "z" "(setq zstrtrusscon $value)") 

		;set the insertion point to what is in the x and y boxes
		(setq insert (list (distof (get_tile "x")) (distof (get_tile "y")))) ;(distof (get_tile "z"))))

		;remember which radio button was chosen last time
		(cond
			((= chir_trusscon nil) (setq chir_trusscon "cw"))
			((= chir_trusscon "cw") (set_tile "cw" "1"))
			((= chir_trusscon "ccw") (set_tile "ccw" "1"))
		)

		;radio buttons
		(action_tile "cw" "(setq chir_trusscon \"cw\")")
		(action_tile "ccw" "(setq chir_trusscon \"ccw\")")

		;in order for the user to be able to press ok, make sure the design constraints are not violated and that the parameter types are correct
		(action_tile "accept" "(checktypestrusscon)")

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
				(setq xstrtrusscon (rtos (car insert)))
				(setq ystrtrusscon (rtos (cadr insert)))
				;(setq zstrtrusscon (rtos (caddr insert)))
			)
		)
	)

	(unload_dialog dcl_id)
	
	;if the dialog was canceled, don't draw anything, otherwise call the appropriate routine to do calculations and drawing
	(if canceled
		(setq canceled nil)
		(progn
			;convert string values to reals or ints
			(setq H (distof Hstrtrusscon))
			(setq H0 (distof H0strtrusscon))
			(setq n (atoi nstrtrusscon))
			(setq a (distof astrtrusscon))
			(setq b (distof bstrtrusscon))
		
			;get the latest point from the box
			(setq insert (list (distof xstrtrusscon) (distof ystrtrusscon) 0)) ;(distof zstrtrusscon)))

			(print H)
			(print H0)
			(print n)
			(print a)
			(print b)
			(print insert)
			(print chir_trusscon)

			;call appropriate drawing routine based on crease pattern type
			(drawtrussmodelcon H H0 n a b insert chir_trusscon)
		)
	)
	(princ)
)