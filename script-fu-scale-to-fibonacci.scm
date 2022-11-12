; Scale to Fibonacci, V1.0
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
; Ensures that a rectangular image has pixel counts for height and
; width that are successive Fibonacci numbers; and that a square image
; has height and width that are the same Fibonacci number.  If not,
; then the image is rescaled so that the longest dimension does not
; increase.
;
; Why would you do this??  Mostly as a prelude to something like
; script-fu-fibonacci-spiral, but that routine has this built in as an
; option.
;
; Located in menu "<Image> / Filters / theilr / Scale to Fibonacci"
;
; USAGE NOTES:
;
;   This script rescales the whole image, not just a layer.
;
;
; SCRIPT SUMMARY: Start generating Fibonacci numbers in a while-loop
;   until the long size of the image is exceeded, then scale back to
;   the previous Fibonacci number pair, and rescale the image so that
;   short and long size (eg, height and width; or vice versa) are
;   successive Fibonacci numbers.  If the image is square, then the
;   rescaling is to the same Fibonacci number.
; 
; Version 1.0
; ==========================================================================



(define (script-fu-scale-to-fibonacci inImage)
  (gimp-image-undo-group-start inImage) 

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
  (gimp-displays-flush)
  (gimp-image-undo-group-end inImage)

  );; end define

(script-fu-register "script-fu-scale-to-fibonacci"
		    "Scale to _Fibonacci"
		    "Rescales image so width and height are Fibonacci numbers"
		    "theilr"
		    "(c) theilr"
		    "Dec 2009"
		    "RGB*"
		    SF-IMAGE "Image"  0
		    )

(script-fu-menu-register "script-fu-scale-to-fibonacci"
			 "<Image>/Filters/_theilr")




  
