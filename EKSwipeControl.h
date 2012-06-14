//
//  EKSwipeControl.h
//  EKSwipeSlider
//
//  Created by Chris Schneider on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


enum {
    EKSwipeControlTapEvent = 1 << 24
};

enum {
    EKSwipeControlOverlayVisibleState = 1 << 3,
    EKSwipeControlOverlayFadedState = 1 << 4
};


@interface EKSwipeControl : UIControl {
    @private
    NSDate *_touchBeganAt;
    CGPoint _initialTouchLocation;
    BOOL _pan;
    NSTimer *_overlayTimer;
    NSMutableDictionary *_overlayColorDict;
}

// Overlay view
@property (strong, nonatomic) IBOutlet UIView *overlayView;

// State
@property (nonatomic, getter=isOverlayVisible) BOOL overlayVisible;
- (void)setOverlayVisible:(BOOL)overlayVisible animated:(BOOL)animated;
@property (nonatomic, getter=isOverlayFaded) BOOL overlayFaded;
- (void)setOverlayFaded:(BOOL)overlayFaded animated:(BOOL)animated;

// Behavior
@property (nonatomic) NSTimeInterval ignoreTapsAfter;
@property (nonatomic, getter=isDelayed) BOOL delayed;

// Layout
- (CGRect)overlayRectForBounds:(CGRect)bounds;
@property (nonatomic) CGPoint anchorPoint;
- (void)centerAnchorPoint;

// Appearance
- (UIColor *)overlayColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setOverlayColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
@property (readonly, strong, nonatomic) UIColor *currentOverlayColor;

@end