//
//  TimeNotchSliderView.m
//  Cook
//
//  Created by Gerald on 1/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "TimeSliderView.h"
#import "ImageHelper.h"

@interface TimeSliderView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation TimeSliderView

#define kControlHeight 50

- (id)init {
    self = [super init];
    if (!self) return nil;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    [self addGestureRecognizer:self.tapGesture];
    
    return self;
}

- (void)sliderTapped:(UIGestureRecognizer *)g {
    UISlider* s = (UISlider*)g.view;
    if (s.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint pt = [g locationInView: s];
    CGFloat percentage = pt.x / s.bounds.size.width;
    CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
    CGFloat value = s.minimumValue + delta;
    [s setValue:value animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end