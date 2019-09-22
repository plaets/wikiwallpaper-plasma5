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

kpackagetool might not be available until you install the plasma sdk/developer tools.
on ubuntu 18.10 you can install kpackagetool using `apt-get install kpackagetool5`

may require installing libqt5quickcontrols2-5 on debian/ubuntu

tested on:

* ubuntu 19.04 / kde 5.15.4 
* ubuntu 18.10 / kde 5.13.5 
* manjaro 18.1.0 / kde 5.16.4
* debian 10 / kde 5.14.5 
* debian 9 / kde 5.8.6 - DOES NOT WORK, requires QtQuick 2.0

## todo

* fix qml warnings about usage of anchors in layout
* publish on plasma store
* add progress spinner/connectivity error indicator to the config window (language list is pulled live from the internet every time)
* optional animations (no idea where to start)
* image resolution/image ratio filter 
* more font settings
* title filter (although you shouldn't use this wallpaper at work anyway)
* category filter
* "next article" keyboard shortcut
* different timer for error handling (would be useful to retry connecting to the internet every minute even if the wallpaper is set to 3 hours update interval)
* investigate why extracts from some articles have no almost text (might be fixed now)

## credits

thanks to [aowznr](https://www.facebook.com/hqanimepics/) for this epic idea
