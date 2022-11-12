(define (script-fu-myblur inImage inLayer inRadius)
  (let * ( ;define local variables
	  (theImage inImage)
	  (theLayer inLayer)
	  (theRadius inRadius)
	  )
    (gimp-image-undo-group-start theImage)       
    (plug-in-gauss RUN-NONINTERACTIVE
		   theImage theLayer theRadius theRadius 0)

    (gimp-image-undo-group-end theImage)
    (gimp-displays-flush)

    )
  )

(script-fu-register "script-fu-myblur"
		    "My _Blur"
		    "Blurs an image"
		    "theilr"
		    "(c) theilr"
		    "24 Oct 2009"
		    "RGB*"
		    SF-IMAGE "Image"  0
		    SF-DRAWABLE "Drawable" 0
		    SF-VALUE  "Radius" "5"
		    )
;(script-fu-menu-register "script-fu-myblur" "<Image>/Filters/_JT")


  