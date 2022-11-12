; Vignette
;
; AUTHOR: theilr (http://flickr.com/photos/theilr), (c) 2012
;
; This script was tested with GIMP 2.8.2
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
; DESCRIPTION: Darkens the corners in a soft way 
;
; The script is located in menu "<Image> / Filters / theilr"
; But it probably belongs in "<Image> / Filters / Decor"
;
; USAGE NOTES: Since this non-destructively produces an overlay layer
; you can make tweaks to the effect
;
; BUGS: Since Gimp 2.10 blur limited to 500 pixels, makes this almost useless
;
; SCRIPT SUMMARY:
; Make new layer, select an ellipse, put gray inside the selection, black
; outside the selection, and then run a Gaussian blur.  Finally, put
; this new layer in overlsy mode.;
; 
; Version 1.0 (Oct 2012) -- 
; =============================================================================


(define (script-fu-vignette inImage inLayer 
			    inDarkenFlag
			    inBlurRadius
			    inOpacity
			    inNoiseFlag)

  (gimp-image-undo-group-start inImage) 

  (let* ( ;define local variables
	 (theWidth (car (gimp-drawable-width inLayer)))
	 (theHeight (car (gimp-drawable-height inLayer)))
	 (theOffsetX (car (gimp-drawable-offsets inLayer)))
	 (theOffsetY (car (cdr (gimp-drawable-offsets inLayer))))
	 (theType (car (gimp-drawable-type inLayer)))
	 (fgColor (car (gimp-context-get-foreground)))
	 (vigLayer (car (gimp-layer-new inImage theWidth theHeight 
					theType "Vignette" 100 NORMAL-MODE)))
	 )

    ;; Set foreground color to gray
    (gimp-context-set-foreground '(127 127 127))

    ;; Align the vig layer with current layer
    (gimp-layer-set-offsets vigLayer theOffsetX theOffsetY)

    ;; Make a black layer with a white border
    (gimp-image-add-layer inImage vigLayer -1)
    (gimp-edit-fill vigLayer WHITE-FILL)
    (if (= inDarkenFlag FALSE)
	(gimp-invert vigLayer) ; ie, BLACK-FILL
	)

    ;; Select ellipse
    (gimp-ellipse-select inImage 
			 theOffsetX theOffsetY
			 theWidth theHeight
			 CHANNEL-OP-ADD FALSE FALSE 0)

    (gimp-edit-fill vigLayer FOREGROUND-FILL) ;; fill ellipse with foreground
    (gimp-selection-none inImage)

    ;; blur the border
    (plug-in-gauss-iir RUN-NONINTERACTIVE inImage vigLayer
		       (min 500 inBlurRadius) TRUE TRUE)

    ;; add spread noise
    (if (= inNoiseFlag TRUE)
	(plug-in-spread RUN-NONINTERACTIVE
			inImage vigLayer 200 200))


    ;; now set the vig layer into overlay mode w/ 50% opacity
    (gimp-layer-set-mode vigLayer OVERLAY-MODE)
    (gimp-layer-set-opacity vigLayer inOpacity)

    ;; reset active layer
    (gimp-image-set-active-layer inImage inLayer)

    ;; reset forground context
    (gimp-context-set-foreground fgColor)

    )

  (gimp-image-undo-group-end inImage)
  (gimp-displays-flush)
  )

(script-fu-register "script-fu-vignette"
		    "_Vignette"
		    "Makes a vignette layer"
		    "theilr"
		    "(c) theilr"
		    "8 Oct 2012"
		    "*"
		    SF-IMAGE "Image"  0
		    SF-DRAWABLE "Drawable" 0
		    SF-OPTION "Vignette" '("Darken Corners" "Lighten Corners")
		    SF-ADJUSTMENT "Blur radius" '(500 0 500 1 50 0 0) ;SF-SLIDER)
		    SF-ADJUSTMENT "Opacity" '(50 0 100 1 50 0 0) ;SF-SLIDER)
		    SF-TOGGLE "Spread Noise" FALSE
		    )

(script-fu-menu-register "script-fu-vignette" "<Image>/Filters/_theilr")




  
