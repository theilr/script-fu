; Square to Golden, V1.0
;
; AUTHOR: theilr (http://flickr.com/photos/theilr), (c) 2009
;
; This script was tested with GIMP 2.6.7
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License Version 3 as 
; published by the Free Software Foundation.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
; GNU General Public License at  http://www.gnu.org/licenses for
; more details.
;
; DESCRIPTION:
;
; Converts a square image into a golden rectangle, but making smaller
; copies, rotating them, and arranging them into a kind of
; golden-rectangle-spiral.  Works best if the square image has a
; Fibonacci number of pixels on a side, but it seems to be sensible
; even when that is not the case. It doesn't test either that the
; image is square or that it has a Fibonacci number of pixels on a
; side.
;
; Located in menu "<Image> / Filters / theilr / Square to Golden"
;
; USAGE NOTES:
;
;   The user can specify the angle (in 90 degree increments, measured
;   clockwise) that the square is turned with each reduction in size.
;   You can also specify if you want the large square on the left or
;   the right side of the rectangle.  To get the spiral effect, you'll
;   either want "90/Left" or "270/Right"
;
;   For non-square images, it still works (ie, doesn't crash), but it
;   ought to be altered to do something more sensible/interesting.  In
;   particular, if you start out with a golden rectangle, and you
;   apply all these transforms, possibly with some layer blending, you
;   could get some new effects.  But for now that doesn't work.
;
; SCRIPT SUMMARY:
;   Take square image;
;   Resize image (ie, canvas) to golden rectangle, keeping image square
;   Copy layer, then:
;       reduce size by factor of golden ratio[*]
;       possibly rotate layer
;       move layer to appropriate position on the spiral
;   Repeat until there's no more room.
;   [*] note, this is not done by multiplying or dividing, but
;       by continually subtacting short from long to get shorter,
;       until the shorter is zero (or less).  then you stop.
; 
; Version 1.0
; ==========================================================================



(define (script-fu-square-to-golden inImage inLayer inRotate inFlip)
  (gimp-image-undo-group-start inImage) 

  (let* 
      ( ;define local variables
       (theWidth (car (gimp-drawable-width inLayer)))
       (theHeight (car (gimp-drawable-height inLayer)))

       (g (/ (+ (sqrt 5) 1) 2)) ;; Golden Ratio: 1.6180339887498949
       (nextSize theHeight)
       (currentSize (round (* theHeight g)))
       (tmpSize)
       (x (- currentSize nextSize))
       (y 0)
       (count 0)

       (cpyLayer)
       (theLayerType)
       )

    (if (= 1 inFlip)
	(begin
	  (gimp-drawable-transform-flip-simple inLayer ORIENTATION-HORIZONTAL
					       TRUE 0 FALSE)
	  (set! inRotate (modulo (- 4 inRotate) 4))))

    (set! cpyLayer (car (gimp-layer-copy inLayer TRUE))) ;copy of layer

    ;; Resize image to Golden Ratio, by expanding the width
    (gimp-image-resize inImage currentSize nextSize x y)

    (while (> (- currentSize nextSize) 0)
     (set! tmpSize nextSize)
     (set! nextSize (- currentSize nextSize))
     (set! currentSize tmpSize)
     (set! count (+ count 1))
     (if (= (modulo count 4) 1)
	 (begin 
	   (set! x (- x nextSize))
	   )
	 )
     (if (= (modulo count 4) 2)
	 (begin 
	   (set! y (+ y currentSize))
	   )
	 )
     (if (= (modulo count 4) 3)
	 (begin 
	   (set! x (+ x currentSize))
	   (set! y (+ y (- currentSize nextSize)))
	   )
	 )
     (if (= (modulo count 4) 0)
	 (begin 
	   (set! x (+ x (- currentSize nextSize)))
	   (set! y (- y nextSize))
	   )
	 )

     (gimp-image-add-layer inImage cpyLayer -1)
     (plug-in-rotate RUN-NONINTERACTIVE inImage cpyLayer inRotate FALSE)
     (gimp-layer-scale-full cpyLayer nextSize nextSize
			    TRUE INTERPOLATION-CUBIC)
     (gimp-layer-set-offsets cpyLayer x y)
     (set! cpyLayer (car (gimp-layer-copy cpyLayer TRUE)))
     );; endwhile

    ;; in case of flip, now flip the whole image back
    (if (= 1 inFlip)
	(gimp-image-flip inImage ORIENTATION-HORIZONTAL))
    
    );; end let*
  (gimp-displays-flush)
  (gimp-image-undo-group-end inImage)

  );; end define

;; DEPRECATED: use script-fu-fibonacci-spiral instead

;; (script-fu-register "script-fu-square-to-golden"
;; 		    "<Image>/Filters/_theilr/_Square-to-Golden-Spiral"
;; 		    "Multiple smaller copies of image arranged in a spiral"
;; 		    "theilr"
;; 		    "(c) theilr"
;; 		    "Dec 2009"
;; 		    "RGB*"
;; 		    SF-IMAGE "Image"  0
;; 		    SF-DRAWABLE "Drawable" 0
;; 		    SF-OPTION "Rotate with each smaller square" '("0" "90" "180" "270")
;; 		    SF-OPTION "Big square to" '("Right" "Left")
;; 		    )

;;(script-fu-menu-register "script-fu-square-to-golden-hdr" "<Image>/Filters/_theilr")


  