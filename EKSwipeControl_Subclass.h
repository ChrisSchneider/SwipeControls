//
//  EKSwipeControl_Subclass.h
//  EKSwipeSlider
//
//  Created by Chris Schneider on 6/13/12.
//
//

#import "EKSwipeControl.h"


typedef id(^EKSwipeControlAppearanceValueBlock)(UIControlState state);

@interface EKSwipeControl ()

// Object Lifecycle
- (void)initializeVariables;
- (void)initializeViews;

// Tracking Utility
- (BOOL)isPan;
- (CGPoint)initialTouchLocation;

// Appearance
- (void)configureAppearance; // Subclasses should overwrite this method!
- (void)configureAppearanceAnimated:(BOOL)animated; // This method should be called!
- (id)findAppearanceValueWithBlock:(EKSwipeControlAppearanceValueBlock)block;

@end