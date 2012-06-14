//
//  EKSwipeSlider.m
//  EKSwipeSlider
//
//  Created by Chris Schneider on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKSwipeSlider.h"
#import "EKSwipeControl_Subclass.h"

#define TRACK_PADDING 2.0f


@implementation EKSwipeSlider

@synthesize value = _value;
@synthesize minimumValue = _minimumValue, maximumValue = _maximumValue;
@synthesize trackView = _trackView;
@synthesize continuous = _continuous;
@synthesize width = _width, offset = _offset;


#pragma mark - Object Lifecycle

+ (void)initialize
{
    [super initialize];
    
    if (self == EKSwipeSlider.class) {
        [self.appearance setOverlayColor:[UIColor colorWithWhite:0.5f alpha:0.5f] forState:EKSwipeControlOverlayVisibleState];
        [self.appearance setOverlayColor:[UIColor colorWithWhite:0.5f alpha:0.3f] forState:EKSwipeControlOverlayFadedState];
        
        [self.appearance setTrackColor:[UIColor colorWithWhite:0.4f alpha:0.5f] forState:EKSwipeControlOverlayVisibleState];
        [self.appearance setTrackColor:[UIColor colorWithWhite:0.4f alpha:0.3f] forState:EKSwipeControlOverlayFadedState];
    }
}

- (void)initializeVariables
{
    [super initializeVariables];
    
    _maximumValue = 1.0f;
    _continuous = YES;
    _trackColorDict = [NSMutableDictionary dictionaryWithCapacity:2];
    _width = 100.0f;
    _offset = 30.0f;
}

- (void)initializeViews
{
    BOOL overlayViewSet = (self.overlayView != nil);
    
    [super initializeViews];
    
    if (!overlayViewSet) {
        self.overlayView.layer.cornerRadius = 6.0f;
    }
    
    if (_trackView == nil) {
        _trackView = [[UIView alloc] init];
        _trackView.layer.cornerRadius = 6.0f;
    }
}


#pragma mark - Subviews Lifecycle

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    if (subview == self.overlayView) {
        [self.overlayView addSubview:self.trackView];
    }
}


#pragma mark - Value

- (void)setValue:(float)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    // Enforce minimum and maximum values
    if (value < self.minimumValue) {
        value = self.minimumValue;
    }
    else if (value > self.maximumValue) {
        value = self.maximumValue;
    }
    
    if (value != _value) {
        _value = value;
        
        // Update overlay if shown
        if (self.overlayView.superview != nil){
            
            // Update animated
            if (animated) {
                [UIView animateWithDuration:0.3f animations:^{
                    self.trackView.frame = [self trackRectForBounds:self.overlayView.bounds];
                }];
            }
            
            // Update without animation
            else {
                self.trackView.frame = [self trackRectForBounds:self.overlayView.bounds];
            }
            
        }
    }
}


#pragma mark Value Limits

- (void)setMinimumValue:(float)minimumValue
{
    if (minimumValue != _minimumValue) {
        _minimumValue = minimumValue;
        
        if (self.maximumValue < self.minimumValue){
            self.maximumValue = self.minimumValue;
        }
        
        // Update value if needed
        if (self.value < minimumValue) {
            self.value = minimumValue;
        }
    }
}

- (void)setMaximumValue:(float)maximumValue
{
    if (maximumValue != _maximumValue) {
        _maximumValue = maximumValue;
        
        if (self.minimumValue > self.maximumValue){
            self.minimumValue = self.maximumValue;
        }

        // Update value if needed
        if (self.value > maximumValue) {
            self.value = maximumValue;
        }
    }
}


#pragma mark - Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL beginTracking = [super beginTrackingWithTouch:touch withEvent:event];
    
    if (beginTracking) {
        _initialValue = _lastSentValue = self.value;
        
        // Update the anchor point
        CGPoint anchorPoint = self.anchorPoint;
        anchorPoint.x -= self.width * (self._trackProportion - 0.5f);
        anchorPoint.y -= self.offset;
        self.anchorPoint = anchorPoint;
    }
    
    return beginTracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL continueTracking = [super continueTrackingWithTouch:touch withEvent:event];
    
    if (continueTracking) {
        CGPoint location = [touch locationInView:self];
        
        // Calculate "delta"
        CGFloat delta = (location.x - self.initialTouchLocation.x) / (self.width - 2.0f * TRACK_PADDING);
        
        // "Translate" delta to new value
        CGFloat value = _initialValue + delta * (self.maximumValue - self.minimumValue);
        self.value = value;
        
        // Send value changed action if continuous
        if (self.isContinuous && self.value != _lastSentValue) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            _lastSentValue = self.value;
        }
    }
    
    return continueTracking;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    // Send value changed action if not continuous
    if (!self.isContinuous && self.value != _initialValue) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
    
    [self setValue:_initialValue animated:YES];
}


#pragma mark - Layout

- (void)setWidth:(CGFloat)width
{
    if (width != _width) {
        _width = width;
        
        [self setNeedsLayout];
    }
}

- (void)setOffset:(CGFloat)offset
{
    if (offset != _offset) {
        _offset = offset;
        
        [self setNeedsLayout];
    }
}

- (CGRect)overlayRectForBounds:(CGRect)bounds
{
    bounds.size = CGSizeMake(self.width, 16.0f);
    return [super overlayRectForBounds:bounds];
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect rect = bounds;
    
    // Padding
    if (rect.size.width >= 2.0f * TRACK_PADDING) {
        rect.origin.x += TRACK_PADDING;
        rect.size.width -= 2.0f * TRACK_PADDING;
    }
    
    if (rect.size.height >= 2.0f * TRACK_PADDING) {
        rect.size.height -= 2.0f * TRACK_PADDING;
        rect.origin.y += TRACK_PADDING;
    }
    
    // Scale / translation
    rect.size.width *= self._trackProportion;
    
    return rect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.trackView.frame = [self trackRectForBounds:self.overlayView.bounds];
}


#pragma mark Layout Utility

- (CGFloat)_trackProportion
{
    // Prevent "nan"
    return (self.maximumValue - self.minimumValue > 0.0f)
        ? fabsf((self.minimumValue - self.value) / (self.maximumValue - self.minimumValue))
        : 0.0f;
}


#pragma mark - Appearance

- (UIColor *)trackColorForState:(UIControlState)state
{
    return [_trackColorDict objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)setTrackColor:(UIColor *)color forState:(UIControlState)state
{
    NSNumber *key = [NSNumber numberWithUnsignedInteger:state];
    
    if (color != [_trackColorDict objectForKey:key]) {
        [_trackColorDict setObject:color forKey:key];
        
        // Update the appearance
        [self configureAppearanceAnimated:NO];
    }
}

- (UIColor *)currentTrackColor
{
    UIColor *color = [self findAppearanceValueWithBlock:^id(UIControlState state) {
        UIColor *color = [self trackColorForState:state];
        
        if (color == nil) {
            color = [self.class.appearance trackColorForState:state];
        }
        
        return color;
    }];
    
    // Fallback
    if (color == nil) {
        color = [UIColor colorWithWhite:0.4f alpha:0.5f];
    }
    
    return color;
}


#pragma mark Appearance Utility

- (void)configureAppearance
{
    [super configureAppearance];
    
    self.trackView.backgroundColor = self.currentTrackColor;
}

@end
