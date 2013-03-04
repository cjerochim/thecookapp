//
//  BookPageDividerView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookLeftPageDividerView.h"

@implementation BookLeftPageDividerView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_pagedivider_left.png"]];
        dividerImageView.frame = self.bounds;
        [self addSubview:dividerImageView];
    }
    return self;
}


@end
