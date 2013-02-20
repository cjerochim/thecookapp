//
//  BookNavigationLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookNavigationLayoutDataSource

- (NSUInteger)bookNavigationContentStartSection;
- (NSUInteger)bookNavigationLayoutNumColumns;
- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BookNavigationLayout : UICollectionViewLayout

- (id)initWithDataSource:(id<BookNavigationLayoutDataSource>)dataSource;

+ (CGSize)unitSize;
+ (UIEdgeInsets)pageInsets;
+ (CGFloat)columnSeparatorWidth;;

@end
