; Fibonacci Spiral, V1.0
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
; Converts a rectangular image into a Fibonacci spiral (similar to a
; "golden spiral" -- the fine distinctions are discussed under the
; wikipedia entry on Golden spiral
; [http://en.wikipedia.org/wiki/Golden_spiral], by making smaller
; copies, rotating them, and arranging them into a spiral tiling.  If
; the initial image is square, then the tiling has no overlap.  Works
; best if the image has a Fibonacci number of pixels as width and
; height, but it does its best even when that is not the case. It
; doesn't test either that the image has a Fibonacci number of pixels
; on a side.
;
; Located in menu "<Image> / Filters / theilr / Golden Spiral"
;
; USAGE NOTES:
;
;   The user can specify the angle (in 90 degree increments, measured
;   clockwise) that the square is turned with each reduction in size.
;   To get the spiral effect, you'll probably want 90.
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

(define (scale-to-fibonacci inImage)
  (let* 
      ( ;define local variables
       (theWidth  (car (gimp-image-width  inImage)))
       (theHeight (car (gimp-image-height inImage)))

       (currentSize 1)
       (nextSize 1)
       (tmpSize)
       (theLongSize (max theWidth theHeight))
       )

    ;; start generating Fibonacci numbers 
    ;; until theLongSize is exceeded -- then scale back 
    ;; by one Fibonacci number
    (while (<= nextSize theLongSize)
     (set! tmpSize nextSize)
     (set! nextSize (+ currentSize nextSize))
     (set! currentSize tmpSize)
     )
    
    (if (= theWidth theHeight)
	(gimp-image-scale inImage currentSize currentSize)
	(if (> theWidth theHeight)
	    (gimp-image-scale inImage currentSize (- nextSize currentSize))
	    (gimp-image-scale inImage (- nextSize currentSize) currentSize)
	    )
	)

    );; end let*
  );; end define


(define (script-fu-golden-spiral inImage inLayer inRescale inRotate)
  (gimp-image-undo-group-start inImage) 

  (let* 
      ( ;define local variables
       (theWidth  (car (gimp-image-width  inImage)))
       (theHeight (car (gimp-image-height inImage)))

       (g (/ (+ (sqrt 5) 1) 2)) ;; Golden Ratio: 1.6180339887498949
       (nextSize)
       (currentSize)
       (tmpSize)
       (x 0)
       (y 0)
       (count 0)
       
       (rotateAngle (+ 1 inRotate))

       (cpyLayer)
       (theLayerType)
       (portraitMode FALSE)
       )

    ;; if portraitMode, then rotate to landscape
    ;; Ensure theWidth >= theHeight
    (if (> theHeight theWidth)
	(begin
	  (gimp-image-rotate inImage ROTATE-90)
	  (set! portraitMode TRUE)
	  )
	)

    ;; if toggle set, then reset image size so width and height
    ;; are Fibonacci numbers
    (if (= inRescale TRUE)
	(scale-to-fibonacci inImage)
	)

    ;; Recompute width and height, given possible rescale and rotation
    (set! theWidth  (car (gimp-image-width  inImage)))
    (set! theHeight (car (gimp-image-height inImage)))

    ;; If it's square, then add some empty width (to layer AND canvas)
    (if (= theHeight theWidth)
	(begin 
	  (set! theWidth (round (* theHeight g)))
	  (gimp-layer-resize inLayer theWidth theHeight 0 0)
	  (gimp-image-resize-to-layers inImage)
	  )
	)
	
    ;; By now, theWidth > theHeight, so 
    (set! nextSize theHeight)    ;; shorter dimension
    (set! currentSize theWidth)  ;; longer dimension

    ;; Now start making scaled-down copies as new layers
    (while (> (- currentSize nextSize) 0)
     (set! tmpSize nextSize)
     (set! nextSize (- currentSize nextSize))
     (set! currentSize tmpSize)
     (set! count (+ count 1))
     (if (= (modulo count 4) 1)
	 (begin 
	   (set! x (+ x currentSize))
	   )
	 )
     (if (= (modulo count 4) 2)
	 (begin 
	   (set! y (+ y currentSize))
	   )
	 )

     (set! cpyLayer (car (gimp-layer-copy inLayer TRUE))) ;copy of layer
     (gimp-image-add-layer inImage cpyLayer -1)
     (if (= (modulo rotateAngle 2) 1)
	 (gimp-layer-scale-full cpyLayer currentSize nextSize
				TRUE INTERPOLATION-CUBIC)
	 (if (= (modulo count 2) 1)
	     (gimp-layer-scale-full cpyLayer nextSize currentSize
				    TRUE INTERPOLATION-CUBIC)
	     (gimp-layer-scale-full cpyLayer currentSize nextSize
				    TRUE INTERPOLATION-CUBIC)
	     )
	 )

     (plug-in-rotate RUN-NONINTERACTIVE inImage cpyLayer 
		     (* rotateAngle count) FALSE)

     (gimp-layer-set-offsets cpyLayer x y)
     );; endwhile

    (if (= portraitMode TRUE)
	(gimp-image-rotate inImage ROTATE-270)
	)

    );; end let*
  (gimp-displays-flush)
  (gimp-image-undo-group-end inImage)

  );; end define

;; DEPRECATED: use script-fu-fibonacci-spiral instead!

;; (script-fu-register "script-fu-golden-spiral"
;; 		    "<Image>/Filters/_theilr/_Golden Spiral"
;; 		    "Multiple smaller copies of image arranged in a spiral"
;; 		    "theilr"
;; 		    "(c) theilr"
;; 		    "Dec 2009"
;; 		    "RGB*"
;; 		    SF-IMAGE "Image"  0
;; 		    SF-DRAWABLE "Drawable" 0
;; 		    SF-TOGGLE "Rescale to Fibonacci" FALSE
;; 		    SF-OPTION "Rotate with each smaller square" 
;; 		    '("90" "180" "270" "360")
;; 		    )




  