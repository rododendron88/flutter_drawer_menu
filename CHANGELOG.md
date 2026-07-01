## [0.1.5]

* Added:
* `handleSystemBack` logic (enabled by default) to allow closing the drawer via system back gesture / back button instead of popping the app route.
* Added an example of custom body transformation (scaling scaling up/down alongside scroll offset) using `DrawerMenuController` to `example` app.

## [0.1.4]

* Fixed:
* Fixed viewport draw order by using `SliverPaintOrder.firstIsTop` instead of manual paint order reversal.
* Tweaked `CustomPageScrollPhysics` spring parameters for smoother menu open/close animation (mass: 1, stiffness: 300, damping: 30).

## [0.1.3]

* Added:
* Fix menuOverlapWidth for tablet mode
* Added the dragMode setting (never, always, onlyFling). onlyFling - the menu opens only by gesture.

## [0.1.2]

* Added:
* menuOverlapWidth - width of the menu overlay above the body. This setting is useful for menu decoration (Shifts the shadow and scrim layer).
* backgroundColor - background color under the menu and body.

## [0.1.0]

* First release