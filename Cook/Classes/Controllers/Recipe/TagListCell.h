//
//  TagListCell.h
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipeTag;

@interface TagListCell : UICollectionViewCell

#define kItemHeight 115
#define kItemWidth 95

@property (nonatomic, strong) CKRecipeTag *recipeTag;

//+ (CGSize)cellSize;

- (void)configureTag:(CKRecipeTag *)recipeTag;

@end
