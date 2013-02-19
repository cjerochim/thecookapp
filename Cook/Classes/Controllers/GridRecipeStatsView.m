//
//  GridRecipeActionsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "GridRecipeStatsView.h"
#import "MRCEnumerable.h"
#import "UIColor+Expanded.h"
#import "CKRecipe.h"
#import "DateHelper.h"

@interface GridRecipeStatsView ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) NSMutableArray *iconViews;

@end

@implementation GridRecipeStatsView

#define kIconLabelFont      [UIFont systemFontOfSize:14.0]
#define kIconLabelColour    [UIColor darkGrayColor]
#define kIconLabelGap       2.0
#define kContentInsets      UIEdgeInsetsMake(0.0, 0.0, 0.0, 3.0)

- (id)init {
    if (self = [super initWithFrame:CGRectZero]) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_recipe_iconbar.png"]];
        self.frame = backgroundView.frame;
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        self.iconViews = [NSMutableArray array];
    }
    return self;
}

- (void)configureRecipe:(CKRecipe *)recipe {
    [self reset];
    [self configureIcon:@"cook_recipe_iconbar_serves.png" value:[NSString stringWithFormat:@"%d", recipe.numServes]];
    [self configureIcon:@"cook_recipe_iconbar_time.png" value:[DateHelper timeDisplayForSeconds:recipe.cookingTimeInSeconds]];
    [self configureIcon:@"cook_recipe_iconbar_comments.png" value:@"0"];
    [self configureIcon:@"cook_recipe_iconbar_likes.png" value:[NSString stringWithFormat:@"%d", recipe.likes]];
}

#pragma mark - Private methods

- (void)reset {
    [self.iconViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.iconViews removeAllObjects];
}

- (void)configureIcon:(NSString *)iconName value:(NSString *)value {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = kIconLabelFont;
    label.textColor = kIconLabelColour;
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.text = value;
    [label sizeToFit];
    label.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + kIconLabelGap,
                             floorf((imageView.frame.size.height - label.frame.size.height) / 2.0),
                             label.frame.size.width,
                             label.frame.size.height);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectUnion(imageView.frame, label.frame))];
    containerView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:imageView];
    [containerView addSubview:label];
    [self.iconViews addObject:containerView];
    
    // Now layout.
    [self layoutIconViews];
}

- (void)layoutIconViews {
    if ([self.iconViews count] > 0) {
        
        CGFloat availableGap = self.bounds.size.width - kContentInsets.left - kContentInsets.right - [self currentOccupiedWidth];
        CGFloat commonGap = availableGap / ([self.iconViews count] + 1);
        CGFloat offset = kContentInsets.left + commonGap;
        
        for (NSUInteger iconIndex = 0; iconIndex < [self.iconViews count]; iconIndex++) {
            UIView *iconView = [self.iconViews objectAtIndex:iconIndex];
            iconView.frame = CGRectMake(offset,
                                        floorf((self.bounds.size.height - iconView.frame.size.height) / 2.0),
                                        iconView.frame.size.width,
                                        iconView.frame.size.height);
            [self addSubview:iconView];
            offset += iconView.frame.size.width + commonGap;
        }
        
    }
}

- (CGFloat)currentOccupiedWidth {
    CGFloat width = 0.0;
    
    for (UIView *iconView in self.iconViews) {
        width += iconView.frame.size.width;
    }
    
    return width;
}

@end
