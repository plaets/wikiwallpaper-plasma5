# wikipedia wallpaper

wikipedia wallaper

* for kde plasma 5
* displays random wikipedia articles/images on your desktop
* lots of configuration options (slightly over-engineered)

## installation

### kde plasma store

TODO

### manual installation

* clone this repo
* enter `kpackagetool5 -t Plasma/Wallpaper --install (path to the cloned repo)`. replace `--install` with `--upgrade` if you are upgrading
* restart plasmashell either by logging out and in again or by entering `plasmashell --replace &` into your terminal
* the wallpaper should be available in the desktop settings (desktop settings are accessible from the context menu of your desktop, i cannot find them in the system settings for some reason)

kpackagetool might not be available until you install the plasma sdk/developer tools
on ubuntu 18.10 you can install kpackagetool using `apt-get install kpackagetool5`

## roadmap

* error handling (it would be cool to get an error message if there is no internet connection)
* fix title positioning for long titles (word wrapping breaks it)
* fix qml warnings about usage of anchors in layout
* publish on plasma store
* optional animations (no idea where to start)
* image resolution/image ratio filter 
* more font settings
* title filter (although you shouldn't use this wallpaper at work anyway)
* category filter
* "next article" keyboard shortcut

## credits

thanks to [aowznr](https://www.facebook.com/hqanimepics/) for this epic idea
