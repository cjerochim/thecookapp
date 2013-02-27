//
//  BookHomeResusableView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookHomeCollectionViewCell.h"
#import "BookHomeViewController.h"
#import "CKBook.h"

@interface BookHomeCollectionViewCell ()

@property (nonatomic, strong) BookHomeViewController *homeViewController;
@property (nonatomic, strong) CKBook *book;

@end

@implementation BookHomeCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)configureBook:(CKBook *)book {
    
    // Don't update if we've already configured it with a book - to prevent refresh of data.
    if (self.book) {
        return;
    }
    
    self.book = book;
}

- (void)configureCategories:(NSArray *)categories {
    [self.homeViewController configureCategories:categories];
}

- (BookHomeViewController *)homeViewController {
    if (_homeViewController == nil) {
        BookHomeViewController *homeViewController = [[BookHomeViewController alloc] initWithBook:self.book];
        homeViewController.view.frame = self.contentView.bounds;
        [self.contentView addSubview:homeViewController.view];
        _homeViewController = homeViewController;
    }
    return _homeViewController;
}

@end
