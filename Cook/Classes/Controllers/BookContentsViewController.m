//
//  BookContentsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentsViewController.h"
#import "CKBook.h"
#import "Theme.h"
#import <Parse/Parse.h>

@interface BookContentsViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *profileImageView;

@end

@implementation BookContentsViewController

#define kContentsWidth      180.0
#define kTitleSize          CGSizeMake(600.0, 300.0)
#define kProfileWidth       200.0
#define kBookTitleInsets    UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kTitleNameGap       0.0

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    // Placed here to get the correct orientation.
    [self initImageView];
    [self initTitleView];
    [self initContentsView];
}

#pragma mark - Private methods

- (void)initImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = CGRectMake(self.view.bounds.origin.x,
                                 self.view.bounds.origin.y,
                                 self.view.bounds.size.width - kContentsWidth,
                                 self.view.bounds.size.height);
    imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)initTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.imageView.bounds.size.width - kTitleSize.width) / 2.0),
                                                                 floorf((self.imageView.bounds.size.height - kTitleSize.height) / 2.0),
                                                                 kTitleSize.width,
                                                                 kTitleSize.height)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    titleView.backgroundColor = [UIColor clearColor];
    [self.imageView addSubview:titleView];
    self.titleView = titleView;
    
    // Semi-transparent black overlay.
    UIView *titleOverlayView = [[UIView alloc] initWithFrame:titleView.bounds];
    titleOverlayView.backgroundColor = [UIColor blackColor];
    titleOverlayView.alpha = 0.8;
    [titleView addSubview:titleOverlayView];
    
    // Profile photo
    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(titleView.bounds.origin.x,
                                                                                  titleView.bounds.origin.y,
                                                                                  kProfileWidth,
                                                                                  titleView.bounds.size.height)];
    profileImageView.backgroundColor = [UIColor darkGrayColor];
    [titleView addSubview:profileImageView];
    self.profileImageView = profileImageView;
    
    // Book title.
    NSString *bookTitle = [self.book.name uppercaseString];
    CGSize availableSize = CGSizeMake(titleView.bounds.size.width - profileImageView.frame.size.width - profileImageView.frame.origin.x - kBookTitleInsets.left - kBookTitleInsets.right, titleView.bounds.size.height - kBookTitleInsets.top - kBookTitleInsets.bottom);
    CGSize size = [bookTitle sizeWithFont:[Theme bookContentsTitleFont] constrainedToSize:availableSize
                            lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + kBookTitleInsets.left + floorf((availableSize.width - size.width) / 2.0),
                                                                    floorf((availableSize.height - size.height) / 2.0),
                                                                    size.width,
                                                                    size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 2;
    titleLabel.font = [Theme bookContentsTitleFont];
    titleLabel.textColor = [Theme bookContentsTitleColour];
    titleLabel.text = bookTitle;
    [titleView addSubview:titleLabel];
    
    // Book author.
    NSString *bookAuthor = [[self.book userName] uppercaseString];
    CGSize authorSize = [bookAuthor sizeWithFont:[Theme bookContentsNameFont] constrainedToSize:availableSize
                                   lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + kBookTitleInsets.left + floorf((availableSize.width - authorSize.width) / 2.0),
                                                                    floorf((availableSize.height - authorSize.height) / 2.0),
                                                                    authorSize.width,
                                                                    authorSize.height)];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    authorLabel.font = [Theme bookContentsNameFont];
    authorLabel.textColor = [Theme bookContentsNameColour];
    authorLabel.text = bookAuthor;
    [titleView addSubview:authorLabel];
    
    // Combined height of title and name, to use for centering.
    CGFloat combinedHeight = titleLabel.frame.size.height + kTitleNameGap + authorLabel.frame.size.height;
    CGRect titleFrame = titleLabel.frame;
    CGRect authorFrame = authorLabel.frame;
    titleFrame.origin.y = kBookTitleInsets.top + floorf((availableSize.height - combinedHeight) / 2.0);
    authorFrame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.size.height + kTitleNameGap;
    titleLabel.frame = titleFrame;
    authorLabel.frame = authorFrame;
}

- (void)initContentsView {
    UIView *contentsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - kContentsWidth,
                                                                    self.view.bounds.origin.y,
                                                                    kContentsWidth,
                                                                    self.view.bounds.size.height)];
    contentsView.backgroundColor = [Theme bookContentsViewColour];
    [self.view addSubview:contentsView];
    self.contentsView = contentsView;
}

@end
