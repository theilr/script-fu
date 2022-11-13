# theilr's script-fu repository

### tl;dr

This repository of GIMP script-fu routines is obsolete; if you are interested in doing the processing/manipulation that these scripts do, you should check out my python-based [Gimp-frastructure](https://github.com/theilr/gimp-frastructure) repository.

### Background

This repository contains a miscellaneous collection of scripts for image processing with the [GNU Image Manipulation Program](https://www.gimp.org/GIMP), aka the GIMP. Most of these routines were initially written in 2009, when I learned how to use *script-fu* to automate tasks that I had been doing by hand.  Several of them were uploaded to the now defunct [Gimp Registry](https://www.gimp.org/registry). There were some minor updates for a few years after that, but for most of the decade, I was distracted by other projects.  Sometime in 2019, I tried running some of my scripts on an updated GIMP, and found that some of them failed, due to changes in GIMP during that time; ffor example, *plug-in-gauss* (which blurs an image by convolving it with a Gaussian kernel of user-specified radius) had a newly added restriction that the blurring radius must be less than 500 pixels.  Some of those routines were modified in 2019 to work around these changes.  In 2022, I re-wrote these scripts as python plug-ins, and it is the python plug-ins that I intend to maintain in the future.

So this is essentially an archival repository.

### List of scripts

Descriptions for what these do can be found in the source code itself.

* script-fu-cheap-hdr

* script-fu-fibonacci-spiral

* script-fu-golden-spiral

* script-fu-jagged-border

* script-fu-myblur

* script-fu-pan-to-bow

* script-fu-quadrupole

* script-fu-scale-to-fibonacci

* script-fu-square-to-golden

* script-fu-text-box

* script-fu-vignette

___

## AUTHOR

I am *theilr* and my photographs are available under that name on my [flickr.com/photos/theilr](http://flickr.com/photos/theilr) site.
As written, these routines end up on the menu at \<Image\>/Filters/theilr/... but
you can put them wherever you like,
by editing the `(script-fu-menu-register ...)` function, which is usually the last
line in the `.scm` file.

### COPYLEFT

These programs are free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License Version 3 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License at  http://www.gnu.org/licenses for
more details.



