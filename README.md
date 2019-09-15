# wikipedia wallpaper

wikipedia wallaper

* for kde plasma 5
* displays random wikipedia articles/images on your desktop
* a lot of configuration options (over engineered)

## installation

* clone this repo
* enter `kpackagetool5 -t Plasma/Wallpaper --upgrade (path to the cloned repo)`
* restart plasmashell either by logging out and in again or by entering `plasmashell --replace &` into your terminal
* the wallpaper should be available in the desktop settings (desktop settings are accessible from the context menu of your desktop, i cannot find them thru the system settings for some reason)

kpackagetool might not be available until you install the plasma sdk/developer tools
on ubuntu 18.10 you can install it using `apt-get install kpackagetool5`

## roadmap

* error handling (yeah... it would be cool to get an error message if there is no internet connection)
* optional animations (no idea where to start)
* image resolution filter
* a way to pick another article on demand either by a keyboard shortcut or by a button somewhere
* a way to copy the article adress to clipboard
* more font settings
* title filter (although you shouldn't use this wallpaper at work anyway)
