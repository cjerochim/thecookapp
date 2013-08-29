//
//  BookTitleView.m
//  CKMaskedLabelDemo
//
//  Created by Jeff Tan-Ang on 30/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleView.h"
#import "CKMaskedLabel.h"
#import "CKBook.h"
#import "CKUserProfilePhotoView.h"

@interface BookTitleView ()

@property (nonatomic, strong) CKMaskedLabel *maskedLabel;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end

@implementation BookTitleView

#define kTitleFont      [UIFont fontWithName:@"BrandonGrotesque-Regular" size:46.0]
#define kSubtitleFont   [UIFont fontWithName:@"BrandonGrotesque-Light" size:24.0]
#define kLabelInsets    (UIEdgeInsets) { 44.0, 73.0, 25.0, 73.0 }

- (id)initWithBook:(CKBook *)book {
    if (self = [self initWithTitle:book.author subtitle:book.name]) {
        
        // Profile photo view.
        self.profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:book.user profileSize:ProfileViewSizeLarge];
        self.profilePhotoView.frame = (CGRect){
            floorf((self.bounds.size.width - self.profilePhotoView.frame.size.width) / 2.0),
            -55.0,
            self.profilePhotoView.frame.size.width,
            self.profilePhotoView.frame.size.height
        };
        [self addSubview:self.profilePhotoView];
        
        // Profile photo frame.
        UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_title_profile_overlay.png"]];
        frameImageView.frame = (CGRect){
            floorf((self.profilePhotoView.bounds.size.width - frameImageView.frame.size.width) / 2.0),
            -5.0,
            frameImageView.frame.size.width,
            frameImageView.frame.size.height
        };
        [self.profilePhotoView addSubview:frameImageView];

    }
    return self;
}

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    if (self = [super initWithFrame:CGRectZero]) {
        self.title = title;
        self.subtitle = subtitle;
        [self initLabel];
    }
    return self;
}

#pragma mark - Private methods

- (void)initLabel {
    
    // Pre-create the label.
    CKMaskedLabel *maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
    maskedLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    maskedLabel.textColour = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    maskedLabel.boxBackgroundColour = [UIColor colorWithWhite:1.0 alpha:0.9];
    maskedLabel.insets = kLabelInsets;
    maskedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    maskedLabel.numberOfLines = 2;
    [self addSubview:maskedLabel];
    self.maskedLabel = maskedLabel;
    
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:kTitleFont];
    NSString *display = [NSString stringWithFormat:@"%@\u2028%@", self.title, self.subtitle];
    
    NSMutableAttributedString *titleDisplay = [[NSMutableAttributedString alloc] initWithString:display attributes:paragraphAttributes];
    if ([self.subtitle length] > 0) {
        [titleDisplay addAttribute:NSFontAttributeName
                             value:kSubtitleFont
                             range:NSMakeRange([display length] - [self.subtitle length], [self.subtitle length])];
    }
    
    self.maskedLabel.attributedText = titleDisplay;
    
    CGSize size = [self.maskedLabel sizeThatFits:(CGSize){ MAXFLOAT, MAXFLOAT }];
    size.width += kLabelInsets.left + kLabelInsets.right;
    size.height += kLabelInsets.top + kLabelInsets.bottom;
    
    self.maskedLabel.frame = (CGRect){ 0.0, 0.0, size.width, size.height };
    self.frame = self.maskedLabel.frame;
    
    // Outer box image.
    UIEdgeInsets boxInsets = (UIEdgeInsets) { 19.0, 19.0, 19.0, 19.0 };
    UIImage *boxImage = [[UIImage imageNamed:@"cook_book_inner_title_box.png"]
                         resizableImageWithCapInsets:(UIEdgeInsets){ 21.0, 21.0, 21.0, 21.0}];
    UIImageView *boxImageView = [[UIImageView alloc] initWithImage:boxImage];
    boxImageView.frame = (CGRect){
        -boxInsets.left,
        -boxInsets.top,
        boxInsets.left + self.bounds.size.width + boxInsets.right,
        boxInsets.top + self.bounds.size.height + boxInsets.bottom,
    };
    [self addSubview:boxImageView];
    
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = 0.0;
    paragraphStyle.paragraphSpacing = 0.0;
//    paragraphStyle.paragraphSpacingBefore = 6.0;
    paragraphStyle.paragraphSpacingBefore = -3.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}


@end
