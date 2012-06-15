# SwipeControls

Swipe Controls display an overlay when the user touches the control. By moving his or her finger (panning) the user can then perform different tasks such as selecting a menu item or changing the value of a volume slider.

**It is recommended to use the swipe slider only as a shortcut and to display a full-featured popover if the user taps the control!** 
For example the audio volume can be quickly adjusted using the swipe-slider. For precise control or AirPlay-configuration a popover with a `MPVolumeView` is displayed.


## Swipe Slider

![Example](http://i50.tinypic.com/2rdusqr.png)

EKSwipeSlider provides a slider similar to `UISlider`. It provides a shortcut to quickly perform tasks such as changing the volume. When tapped it is recommended to display a full-featured popover.

![Example](http://i48.tinypic.com/24g6sjr.png)  

When displayed the slider adjusts its position on the x-axis depending on the value. The orange points represent the touch points.

## Swipe Menu

Coming soon :-)


## Documentation

### Controls

* [EKSwipeControl](https://github.com/ChrisSchneider/SwipeControls/wiki/EKSwipeControl)
* [EKSwipeSlider](https://github.com/ChrisSchneider/SwipeControls/wiki/EKSwipeSlider)

### Articles

* [Examples](https://github.com/ChrisSchneider/SwipeControls/wiki/Examples)
* [Creating Subclasses](https://github.com/ChrisSchneider/SwipeControls/wiki/Subclassing-EKSwipeControl)


## Linked Binaries

SwipeControls needs the following frameworks ("Link Binary With Libraries"):

* Foundation.framework
* UIKit.framework
* QuartzCore.framework
* CoreGraphics.framework


## License

This work is licensed under the [Creative Commons Attribution-ShareAlike 3.0 Germany License](http://creativecommons.org/licenses/by-sa/3.0/de/).