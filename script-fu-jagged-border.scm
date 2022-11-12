; Jagged Border, V1.3
;
; AUTHOR: theilr (http://flickr.com/photos/theilr), (c) 2009
;
; This script was tested with GIMP 2.6.7
; V1.3 tested with GIMP 2.8.2
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
; DESCRIPTION: Creates a white (or black) border around an image that
; merges in with the image so that on a larger white (or black)
; background, the image appears to have a ragged border.  This is
; similar to the Gimp's Fuzzy Border, but it adapts its jaggedness to
; the image. (Also unlike Fuzzy Border, it is deterministic, it does
; not depend on random number seeds.)
;
; The script is located in menu "<Image> / Filters / theilr"
; But it probably belongs in "<Image> / Filters / Decor"
;
; USAGE NOTES: Since this non-destructively produces a border as a
; separate layer, you can tweak the border; eg smooth it (yuck, then
; it's not very jagged anymore!), change its color, use it to build
; some fancy drop-shadow, etc.  A number of effects can be obtained by
; using the white/black border layer and/or its inverse as a layer
; mask.
;
; You can apply the border to other images.  For instance, you can
; make a high (or low) contrast version of your image for the purpose
; of making the border, but once you have the border, you can apply it
; to your original image.
;
; If you check "Enforce one-pixel border" than your border will be at least
; one pixel wide around the whole image. Usually you won't need this, but
; if you have very dark things at the border of the image, they might get
; in the way of the fuzzy select. -- actually, I recommend its usage as a
; matter of course
;
; If you apply this to a layer that is smaller than the image, then the
; border will just be around the layer.  But only rectangular layers work.
;
; BUGS:
; Smooth amount is assumed to be double the border size; this is ad hoc
; Ideally, the border would adjust itself to be as narrow as possible at
;   its thinnest point.  No point wasting good pixels!
; Currently, the border is "seeded" from UL and LR corners, can forsee
;   situations when this would be inadequate; eg, very dark component
;   running through the border.  I'm implemented workaround that basically
;   adds a one-pixel border around the whole image.
; Threshold is a parameter, but in practice I always use 1, maybe should
;   just remove it as a parameter.
; Rectangular border (default) is achieved by running horiz and then vert;
;   it is possible that this will leave some islands near the corners, even
;   if "Fill in the islands" is set to true.  Also, you'll get two border
;   layers, and if you want one you'll have to merge by hand
; Assumes that the layer is rectangular.
; I can imagine neat effects where you might want to specify (eg, with a
;   selection) a border that only surrounds part of your image.
; No way to interactively change a lot of these parameters; you just
;    have to try different values and see what you get
; Need a better name for this script (ragged border? adaptively ragged?)
; Q: does it make sense to have borders any color other than black or white?
; Gimp 2.10 introduced a restriction on blur radius, must be less than 500
;
; SCRIPT SUMMARY:
; Make new layer which is black with a white border, blur the border,
; add the new layer to a copy of the image of interest, select the
; white area, and throw away that temporary layer.  Make a new layer,
; which is white over the selection (which is the border area),
; and black in the interior.  This layer is in ADDITION-MODE, and so
; the black interior is effectively transparent.
;
; To make black borders, the strategy is essentially the same, except
; that the original image is inverted before being added to the blurred
; white frame.  After the new border layer is generated, it is inverted,
; and changed from ADDITION-MODE to MULTIPLY-MODE.
;
;
;
; Version 1.0 (Oct 2009) --
; Version 1.1 (Nov 2009) -- added option for black borders
; Version 1.2 (Dec 2009) -- work on layers that are smaller than image
; Version 1.3 (Oct 2012) -- make rectangular do horiz then vert
; Version 1.4 (Mar 2019) -- restrict blur to max of 500
; =============================================================================


(define (script-fu-jagged-border inImage inLayer
				 inBorderShape
				 inBlackBorder
				 inBorderSize
				 inThresh
				 inFillIslands
				 inOnePixelBorder)

  (gimp-image-undo-group-start inImage)
  (if (= inBorderShape 0) ;; Rectangular
      (begin (jagged-border-run inImage inLayer 1
				inBlackBorder inBorderSize inThresh
				inFillIslands inOnePixelBorder)
	     (jagged-border-run inImage inLayer 2
				inBlackBorder inBorderSize inThresh
				inFillIslands inOnePixelBorder)
	     )
      (jagged-border-run inImage inLayer inBorderShape
			 inBlackBorder inBorderSize inThresh
			 inFillIslands inOnePixelBorder)
      )
  (gimp-image-undo-group-end inImage)
  (gimp-displays-flush)
)


(define (jagged-border-run inImage inLayer
			   inBorderShape
			   inWhiteBorder
			   inBorderSize
			   inThresh
			   inFillIslands
			   inOnePixelBorder)

  (let* ( ;define local variables
	 (theWidth (car (gimp-drawable-width inLayer)))
	 (theHeight (car (gimp-drawable-height inLayer)))
	 (theOffsetX (car (gimp-drawable-offsets inLayer)))
	 (theOffsetY (car (cdr (gimp-drawable-offsets inLayer))))
	 (theType (car (gimp-drawable-type inLayer)))
	 (cpyLayer (car (gimp-layer-copy inLayer TRUE))) ;copy of layer
	 (tmpLayer (car (gimp-layer-new inImage theWidth theHeight
					theType "tmp" 100 NORMAL-MODE)))
	 (bdrLayer (car (gimp-layer-new inImage theWidth theHeight
					theType "Border" 100 NORMAL-MODE)))
	 )


    ;; Align the two new layers (tmp and bdr) with current layer
    (gimp-layer-set-offsets tmpLayer theOffsetX theOffsetY)
    (gimp-layer-set-offsets bdrLayer theOffsetX theOffsetY)

    ;; Make a black layer with a white border
    (gimp-image-add-layer inImage tmpLayer -1)
    (gimp-edit-fill tmpLayer WHITE-FILL)
    (gimp-invert tmpLayer) ; ie, BLACK-FILL

    ;; Make a selection, equivalent to shrinking in by inBorderSize
    (if (= inBorderShape 0) ;; Rectangular
	;;; NOTE: This should never happen!
	(gimp-rect-select inImage
			  (+ inBorderSize theOffsetX)
			  (+ inBorderSize theOffsetY)
			  (- theWidth (* inBorderSize 2))
			  (- theHeight (* inBorderSize 2))
			  CHANNEL-OP-ADD FALSE 0)
	)
    (if (= inBorderShape 1) ;; Horizontal only
	(gimp-rect-select inImage
			  theOffsetX
			  (+ inBorderSize theOffsetY)
			  theWidth
			  (- theHeight (* inBorderSize 2))
			  CHANNEL-OP-ADD FALSE 0)
	)
    (if (= inBorderShape 2) ;; Vertical only
	(gimp-rect-select inImage
			  (+ inBorderSize theOffsetX)
			  theOffsetY
			  (- theWidth (* inBorderSize 2))
			  theHeight
			  CHANNEL-OP-ADD FALSE 0)
	)
    (if (= inBorderShape 3) ;; Elliptical
	(gimp-ellipse-select inImage
			     (+ inBorderSize theOffsetX)
			     (+ inBorderSize theOffsetY)
			     (- theWidth (* inBorderSize 2))
			     (- theHeight (* inBorderSize 2))
			     CHANNEL-OP-ADD FALSE FALSE 0)
	)
    (if (= inBorderShape 4) ;; Rounded regtangular
	(gimp-rect-select inImage
			  (+ inBorderSize theOffsetX)
			  (+ inBorderSize theOffsetY)
			  (- theWidth (* inBorderSize 2))
			  (- theHeight (* inBorderSize 2))
			  CHANNEL-OP-ADD FALSE 0)
	)

    (gimp-selection-invert inImage)
    (gimp-edit-fill tmpLayer WHITE-FILL)
    (gimp-selection-none inImage)
    ;; blur the border
    ;; (plug-in-gauss-iir RUN-NONINTERACTIVE inImage tmpLayer
    ;;	       (min 500 (* inBorderSize 2)) TRUE TRUE)
    (plug-in-gauss RUN-NONINTERACTIVE inImage tmpLayer
	       (min 500 (* inBorderSize 2))
	       (min 500 (* inBorderSize 2))
	       0)

    ;; Now put up a copy of the image, to be added to this border layer
    (gimp-image-add-layer inImage cpyLayer -1)
    (if (= RGB-IMAGE theType)
	;; make it a desaturated image (does this help?)
	(gimp-desaturate cpyLayer)
	)
    (if (= inWhiteBorder 0)
	  (gimp-invert cpyLayer)
	  )
    (if (= inOnePixelBorder 1)
	;; add a single layer of white pixels around the image (good idea?)
	;; it does waste border pixels in horiz-only or vert-only modes
	;; but it ensures that the entire border will be generated
	(begin
	  ;(gimp-selection-all inImage)
	  (gimp-rect-select inImage
			    theOffsetX theOffsetY
			    theWidth theHeight
			    CHANNEL-OP-ADD FALSE 0)
	  (gimp-selection-shrink inImage 1)
	  (gimp-selection-invert inImage)
	  (gimp-edit-fill cpyLayer WHITE-FILL)
	  (gimp-selection-none inImage)
	  )
	)

    (gimp-layer-set-mode cpyLayer ADDITION-MODE)

    ;; When we merge down we need to capture the identity
    ;; of the merged layer, rename it tmpLayer
    (set! tmpLayer (car (gimp-image-merge-down inImage cpyLayer 0)))

    ;; select the white border, then remove the tmp layer
    ;; because all we care about is the selection
    (gimp-fuzzy-select tmpLayer 0 0
		       inThresh CHANNEL-OP-ADD TRUE FALSE 0 FALSE)
    (gimp-fuzzy-select tmpLayer
		       (- theWidth 1)
		       (- theHeight 1)
		       inThresh CHANNEL-OP-ADD TRUE FALSE 0 FALSE)
    (gimp-image-remove-layer inImage tmpLayer) ;; ok, we're done with you

    ;; now make a new layer
    (gimp-image-add-layer inImage bdrLayer -1)
    (gimp-drawable-fill bdrLayer WHITE-FILL) ;; make it white everywhere
    (gimp-selection-invert inImage)          ;; select the interior
    (gimp-invert bdrLayer) ;; black in the middle, white on the border
    (gimp-selection-none inImage)            ;; ok, we're done with you
    (gimp-layer-set-mode bdrLayer ADDITION-MODE)

    (if (= inFillIslands 1)
	(begin
	  (gimp-fuzzy-select bdrLayer (/ theWidth 2) (/ theHeight 2)
			     127 CHANNEL-OP-ADD TRUE FALSE 0 FALSE)
	  (gimp-selection-invert inImage)
	  (gimp-edit-fill bdrLayer WHITE-FILL) ;; fill in the islands
	  (gimp-selection-none inImage)
	  )
	)

    (if (= inWhiteBorder 0)
	(begin
	  (gimp-invert bdrLayer)
	  (gimp-layer-set-mode bdrLayer MULTIPLY-MODE)
	  )
	)

    (gimp-image-set-active-layer inImage inLayer)


    )
  )

(script-fu-register "script-fu-jagged-border"
		    "_Jagged Border"
		    "Make a jagged border whose jags adapt to the image"
		    "theilr"
		    "(c) theilr"
		    "31 Mar 2019"
		    "*"
		    SF-IMAGE "Image"  0
		    SF-DRAWABLE "Drawable" 0
		    SF-OPTION "Border shape" '("Rectangular"
					       "Horizontal only"
					       "Vertical only"
					       "Elliptical"
					       "Rounded rectangular"
					       )
		    SF-OPTION "Border color" '("Black" "White")
		    SF-ADJUSTMENT "Border width" '(250 0 1000 1 50 0 SF-SLIDER)
		    SF-ADJUSTMENT "Threshold" '(1 0 255 1 10 0 SF-SLIDER)
		    SF-TOGGLE "Fill in the islands" TRUE
		    SF-TOGGLE "Enforce one-pixel border" TRUE
		    )
(script-fu-menu-register "script-fu-jagged-border" "<Image>/Filters/_theilr")
