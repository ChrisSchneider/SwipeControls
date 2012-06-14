//
//  EKSwipeControl.m
//  EKSwipeSlider
//
//  Created by Chris Schneider on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKSwipeControl.h"
#import "EKSwipeControl_Subclass.h"

#define FADE_IN_DURATION 0.15f
#define FADE_OUT_DURATION 0.1f
#define TRANSITION_DURATION 0.2f

#define DELAY 0.15f
#define MINIMUM_PAN_DISTANCE 3.0f


@implementation EKSwipeControl

@synthesize overlayView = _overlayView;
@synthesize overlayVisible = _overlayVisible, overlayFaded = _overlayFaded;
@synthesize ignoreTapsAfter = _ignoreTapsAfter, delayed = _delayed;
@synthesize anchorPoint = _anchorPoint;


#pragma mark - Object Lifecycle

+ (void)initialize
{
    [super initialize];
    
    if (self == EKSwipeControl.class) {
        [self.appearance setOverlayColor:UIColor.clearColor forState:UIControlStateNormal];
        [self.appearance setOverlayColor:UIColor.clearColor forState:EKSwipeControlOverlayVisibleState];
        [self.appearance setOverlayColor:UIColor.clearColor forState:EKSwipeControlOverlayFadedState];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initializeVariables];
        [self initializeViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeVariables];
        [self initializeViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeVariables];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initializeViews];
}

- (void)initializeVariables
{
    _initialTouchLocation = CGPointZero;
    _ignoreTapsAfter = 0.3f;
    _delayed = YES;
    _overlayColorDict = [NSMutableDictionary dictionaryWithCapacity:2];
}

- (void)initializeViews
{
    if (_overlayView == nil) {
        _overlayView = [[UIView alloc] init];
        
        CALayer *layer = _overlayView.layer;
        layer.shadowColor = UIColor.blackColor.CGColor;
        layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        layer.shadowOpacity = 0.8f;
        layer.shadowRadius = 2.0f;
    }
    
    else if (self.overlayView.superview != nil) {
        [self.overlayView removeFromSuperview];
    }
}


#pragma mark - KVO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"state"]) {
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:@"overlayVisible", @"overlayFaded", nil]];
    }
    
    return keyPaths;
}


#pragma mark - State

- (UIControlState)state
{
    UIControlState state = super.state;
    
    if (self.isOverlayVisible) {
        state |= EKSwipeControlOverlayVisibleState;
    }
    
    if (self.isOverlayFaded) {
        state |= EKSwipeControlOverlayFadedState;
    }
    
    return state;
}

- (void)setHighlighted:(BOOL)highlighted
{
    BOOL wasHighlighted = self.isHighlighted;
    
    [super setHighlighted:highlighted];
    
    if (highlighted != wasHighlighted) {
        [self configureAppearanceAnimated:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    BOOL wasSelected = self.isSelected;
    
    [super setHighlighted:selected];
    
    if (selected != wasSelected) {
        [self configureAppearanceAnimated:NO];
    }
}

- (void)setOverlayVisible:(BOOL)overlayVisible
{
    [self setOverlayVisible:overlayVisible animated:NO];
}

- (void)setOverlayVisible:(BOOL)overlayVisible animated:(BOOL)animated
{
    if (overlayVisible != _overlayVisible) {
        _overlayVisible = overlayVisible;
        
        // Show
        if (overlayVisible) {
            [self addSubview:self.overlayView];
            self.overlayView.frame = [self overlayRectForBounds:self.bounds];
            [self configureAppearanceAnimated:NO];
            
            // Animate
            if (animated) {
                __block CGFloat toAlpha = self.overlayView.alpha;
                __block CGAffineTransform toTransform = self.overlayView.transform;
                
                self.overlayView.alpha = 0.0f;
                self.overlayView.transform = CGAffineTransformMakeScale(0.1f, 0.4f);
                
                [UIView animateWithDuration:FADE_IN_DURATION animations:^{
                    self.overlayView.alpha = toAlpha;
                    self.overlayView.transform = toTransform;
                }];
            }
        }
        
        // Hide animated
        else if (animated) {
            __block CGFloat resetAlpha = self.overlayView.alpha;
            
            [UIView animateWithDuration:FADE_OUT_DURATION animations:^{
                self.overlayView.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                [self.overlayView removeFromSuperview];
                self.overlayView.alpha = resetAlpha;
            }];
        }
        
        // Hide without animation
        else {
            [self.overlayView removeFromSuperview];
        }
    }
}

- (void)setOverlayFaded:(BOOL)overlayFaded
{
    [self setOverlayFaded:overlayFaded animated:NO];
}

- (void)setOverlayFaded:(BOOL)overlayFaded animated:(BOOL)animated
{
    if (overlayFaded != _overlayFaded) {
        _overlayFaded = overlayFaded;
        
        [self configureAppearanceAnimated:animated];
    }
}


#pragma mark - Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL beginTracking = [super beginTrackingWithTouch:touch withEvent:event];
    
    if (beginTracking) {
        self.anchorPoint = _initialTouchLocation = [touch locationInView:self];
        self.overlayFaded = YES;
        _touchBeganAt = [NSDate dateWithTimeIntervalSinceNow:0.0f];
        
        // Schedule timer if delayed
        if (self.isDelayed) {
            _overlayTimer = [NSTimer scheduledTimerWithTimeInterval:DELAY
                                                             target:self
                                                           selector:@selector(_showOverlay)
                                                           userInfo:nil
                                                            repeats:NO];
        }
        
        // Show overlay if not delayed
        else {
            [self _showOverlay];        
        }
    }
    
    return beginTracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL continueTracking = [super continueTrackingWithTouch:touch withEvent:event];
    
    // If no pan has been recognized yet...
    if (continueTracking && !self.isPan) {
        
        // Get distance from initial location
        CGPoint location = [touch locationInView:self];
        CGSize delta = CGSizeMake(fabsf(location.x - self.anchorPoint.x), fabsf(location.y - self.anchorPoint.y));
        CGFloat distance = sqrtf(delta.width * delta.width + delta.height * delta.height);
        
        // Pan recognized?
        if (distance >= MINIMUM_PAN_DISTANCE) {
            _pan = YES;
            
            // Unfade the overlay
            [self setOverlayFaded:NO animated:YES];
        }
    }
    
    return continueTracking;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self _hideOverlay];
    
    // Propagate tap if it happened within the given time
    if (!self.isPan && -_touchBeganAt.timeIntervalSinceNow < self.ignoreTapsAfter) {
        [self sendActionsForControlEvents:EKSwipeControlTapEvent];
    }
    
    // Reset
    _pan = NO;
    _initialTouchLocation = CGPointZero;
    _touchBeganAt = nil;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self _hideOverlay];
    
    // Reset
    _pan = NO;
    _initialTouchLocation = CGPointZero;
    _touchBeganAt = nil;
}


#pragma mark Tracking Utility

- (BOOL)isPan
{
    return _pan;
}

- (CGPoint)initialTouchLocation
{
    return _initialTouchLocation;
}

- (void)_showOverlay
{
    // Show overlay animated
    [self setOverlayVisible:YES animated:YES];
    
    _overlayTimer = nil;
}

- (void)_hideOverlay
{
    // Overlay has not been shown yet -> invalidate the timer
    if (_overlayTimer != nil) {
        [_overlayTimer invalidate];
        _overlayTimer = nil;
    }
    
    // Overlay is visible -> hide it
    else {
        [self setOverlayVisible:NO animated:YES];
    }
}


#pragma mark - Layout

- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    if (!CGPointEqualToPoint(anchorPoint, _anchorPoint)) {
        _anchorPoint = anchorPoint;
        
        [self setNeedsLayout];
    }
}

- (void)centerAnchorPoint
{
    self.anchorPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
}

- (CGRect)overlayRectForBounds:(CGRect)bounds
{
    CGRect rect = bounds;
    rect.origin.x = self.anchorPoint.x - rect.size.width / 2.0f;
    rect.origin.y = self.anchorPoint.y - rect.size.height / 2.0f;
    return rect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    self.overlayView.frame = [self overlayRectForBounds:self.bounds];
}


#pragma mark - Appearance

- (UIColor *)overlayColorForState:(UIControlState)state
{
    return [_overlayColorDict objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)setOverlayColor:(UIColor *)color forState:(UIControlState)state
{
    NSNumber *key = [NSNumber numberWithUnsignedInteger:state];
    
    if (color != [_overlayColorDict objectForKey:key]) {
        [_overlayColorDict setObject:color forKey:key];
        
        // Update the presentation
        [self configureAppearanceAnimated:NO];
    }
}

- (UIColor *)currentOverlayColor
{
    UIColor *color = [self findAppearanceValueWithBlock:^id(UIControlState state) {
        UIColor *color = [self overlayColorForState:state];
        
        if (color == nil) {
            color = [self.class.appearance overlayColorForState:state];
        }
        
        return color;
    }];
    
    // Fallback
    if (color == nil) {
        color = UIColor.clearColor;
    }
    
    return color;
}


#pragma mark Appearance Utility

- (void)configureAppearance
{
    self.overlayView.backgroundColor = self.currentOverlayColor;
}

- (void)configureAppearanceAnimated:(BOOL)animated
{
    // Only update the view if the overlay is visible
    if (self.isOverlayVisible) {
        if (animated) {
            [UIView animateWithDuration:TRANSITION_DURATION animations:^{
                [self configureAppearance];
            }];
        }
        else {
            [self configureAppearance];
        }        
    }
}

- (id)findAppearanceValueWithBlock:(EKSwipeControlAppearanceValueBlock)block
{
    // Get the value for the current state
    id value = block(self.state);
    
    // --> Might fall back to faded state...
    if (value == nil && (self.state & EKSwipeControlOverlayFadedState) == EKSwipeControlOverlayFadedState) {
        value = block(EKSwipeControlOverlayFadedState);
    }
    
    // --> Might fall back to visible state...
    if (value == nil && (self.state & EKSwipeControlOverlayVisibleState) == EKSwipeControlOverlayVisibleState) {
        value = block(EKSwipeControlOverlayVisibleState);
    }
    
    // --> Fallback to normal state
    if (value == nil) {
        value = block(UIControlStateNormal);
    }
    
    return value;
}

@end