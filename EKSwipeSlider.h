//
//  EKSwipeSlider.h
//  EKSwipeSlider
//
//  Created by Chris Schneider on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKSwipeControl.h"


@interface EKSwipeSlider : EKSwipeControl {
    @private
    CGFloat _initialValue;
    CGFloat _lastSentValue;
    NSMutableDictionary *_trackColorDict;
}

// Value
@property (nonatomic) float value;
- (void)setValue:(float)value animated:(BOOL)animated;

// Value Limits
@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;

// Track view
@property (strong, nonatomic) IBOutlet UIView *trackView;

// Behavior
@property (nonatomic, getter=isContinuous) BOOL continuous;

// Layout
- (CGRect)trackRectForBounds:(CGRect)bounds;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat offset;

// Appearance
- (UIColor *)trackColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setTrackColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
@property (readonly, strong, nonatomic) UIColor *currentTrackColor;

@end