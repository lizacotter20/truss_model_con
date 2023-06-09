(defun makeplate (insertp b param n d_r d_c p1 p2 / bar_radius hole_radius hole_depth plate_thickness 
											  insert2 rad halfwindowside bottomleft toprightrhole cyl poly holes holept plate bottomcirclept negbottomcirclept topcirclept)

	;zoom to drawing area (with margin room)
	(command "_ucs" "W")
	(command "_view" "TOP")
	(setq rad (/ b (* 2 (sin param))))
	(setq halfwindowside (* 3 rad))
	(setq bottomleft (list (- (car insertp) halfwindowside) (- (cadr insertp) halfwindowside)))
	(setq topright (list (+ (car insertp) halfwindowside) (+ (cadr insertp) halfwindowside)))
	(setq negbottomleft (list (* -1 (- (car insertp) halfwindowside)) (- (cadr insertp) halfwindowside)))
	(setq negtopright (list (* -1 (+ (car insertp) halfwindowside)) (+ (cadr insertp) halfwindowside)))
	(command "_zoom" bottomleft topright)
	(print "zoom")

	;plate parameters
	(setq hole_radius 0.03) ;magnet holes
	(setq hole_depth 0.04) ;magnet holes
	(setq cyl_radius (/ d_c 2)) ;middle hole
	(setq bar_radius (/ d_r 2))
	(setq plate_thickness d_r)
	
	(setq insert2 (list (car insertp) (cadr insertp) (- (caddr insertp) (/ plate_thickness 2))))
	(print "params")

	;make the top and bottom plates 
	;middle cylinder
	(command "_circle" insert2 cyl_radius)
	(command "_extrude" (entlast) "" 0.1)
	(setq cyl (ssget "L"))
	(print "cyls")

	;make the plate 
	(command "_polygon" n insertp "I" p1)
	(setq poly (ssget "L"))
	(print "poly")

	;for some reason the polygon interferes with the drawing of the magnet holes (and vice versa), so put it in a layer and hide it for now
	(command "_layer" "_n" "polylay" "")
	(command "_layer" "_color" 4 "polylay" "")
	(command "_change" (entlast) "" "_p" "_la" "polylay" "")
	(command "_layer" "off" "polylay" "")
	(print "polylay")

	;make a selection set for all the cylinders (that will become magnet holes)
	(setq holes (ssadd))
	(setq beta (- (/ pi 2) param)) ;half an internal angle
	(setq holept (list (+ (car insertp) (- rad (* hole_radius (csc beta)))) (cadr insertp) (+ (caddr insertp) (- (- plate_thickness hole_depth) (/ plate_thickness 2)))))
	(command "_circle" holept hole_radius)
	(command "_extrude" (entlast) "" (* 2 plate_thickness))
	(ssadd (entlast) holes)
	(repeat (- n 1)
		(command "rotate" (entlast) "" insertp "C" (/ 360.0 n))
		(ssadd (entlast) holes)
	)
	;turn the layer with the polyogn back on
	(command "_layer" "on" "polylay" "")

	;extrude the plate, move such that the xy plane halves it laterally
	(command "_extrude" poly "" plate_thickness)
	(setq plate (ssget "L"))
	(command "_move" (entlast) "" insertp insert2)
	

	;make cyclinders all around the polygon
	(command "_cylinder" p1 bar_radius "A" p2)
	(ssadd (entlast) plate)
	(repeat (- n 1)
		(command "rotate" (entlast) "" insertp "C" (/ 360.0 n))
		(ssadd (entlast) plate)
	)

	;make spheres at the points of the polygon
	(command "_sphere" p1 bar_radius)
	(ssadd (entlast) plate)
	(repeat (- n 1)
		(command "rotate" (entlast) "" insertp "C" (/ 360.0 n))
		(ssadd (entlast) plate)
	)

	(command "_union" plate "")
	(setq liza jeffery)
	(print "HALLO")

	;and subtract the holes
	(command "_subtract" (entlast) "" cyl holes"")
	

	;fillet center hole edges 
	(command "_view" "BOTTOM")
	(command "_zoom" negbottomleft negtopright)
	(setq bottomcirclept (list (+ (car insertp) rhole) (cadr insertp) (caddr insertp)))
	(setq negbottomcirclept (list (* -1 (+ (car insertp) rhole)) (cadr insertp) (caddr insertp)))
	(command "_filletedge" "L" negbottomcirclept "" "R" (/ plate_thickness 2) "" "")
	(command "_view" "TOP")
	(command "_zoom" bottomleft topright)
	(setq topcirclept (list (+ (car insertp) rhole) (cadr insertp) (+ (caddr insertp) plate_thickness))) ;
	(command "_filletedge" "L" topcirclept "" "R" (/ plate_thickness 2) "" "")

	(command "_union" plate "")


)