//
//  CKPagingCollectionViewLayout.m
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingCollectionViewLayout.h"
#import "MRCEnumerable.h"

@interface PagingCollectionViewLayout ()

@property (nonatomic, weak) id<PagingCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL physicsEnabled;

@property (nonatomic, strong) NSMutableArray *anchorPoints;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

@implementation PagingCollectionViewLayout

#define kContentInsets                  UIEdgeInsetsMake(165.0, 362.0, 155.0, 362.0)
#define kBookSize                       (CGSize){ 300.0, 438.0 }
#define kSideMargin                     62.0
#define kMyBookSection                  0
#define kFollowSection                  1
#define kBookScaleFactor                1.1
#define kBookDeleteScaleFactor          0.9

+ (CGSize)bookSize {
    return kBookSize;
}

- (id)initWithDelegate:(id<PagingCollectionViewLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)markLayoutDirty {
    self.layoutCompleted = NO;
}

- (void)enableEditMode:(BOOL)editMode {
    self.editMode = editMode;
    [self markLayoutDirty];
}

- (CGRect)frameForGap {
    return (CGRect){
        (kSideMargin + kBookSize.width) + kBookSize.width,
        kContentInsets.top,
        kBookSize.width,
        kBookSize.height
    };
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForMyBook {
    NSIndexPath *myBookIndexPath = [NSIndexPath indexPathForItem:0 inSection:kMyBookSection];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:myBookIndexPath];
    attributes.frame = (CGRect) {
        kContentInsets.left,
        kContentInsets.top,
        kBookSize.width,
        kBookSize.height
    };
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForFollowBookAtIndex:(NSInteger)bookIndex {
    
    // Compulsory gap: my book + empty book
    CGPoint cellOffset = (CGPoint) {
        kContentInsets.left + kBookSize.width + kBookSize.width,
        kContentInsets.top
    };
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:bookIndex inSection:kFollowSection];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = (CGRect) {
        cellOffset.x + (bookIndex * kBookSize.width),
        kContentInsets.top,
        kBookSize.width,
        kBookSize.height
    };
    return attributes;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    CGSize minSize = self.collectionView.bounds.size;
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    CGFloat emptyBookGap = kBookSize.width;
    
    CGSize requiredSize = (CGSize){
        kContentInsets.left + kBookSize.width + emptyBookGap + (numFollowBooks * kBookSize.width) + kContentInsets.right,
        self.collectionView.bounds.size.height
    };
    
    return requiredSize.width > minSize.width ? requiredSize : minSize;
}

- (void)prepareLayout {
    [self buildLayout:NO];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    if (!self.physicsEnabled) {
        return YES;
    }
    
    CGFloat scrollDelta = newBounds.origin.x - self.collectionView.bounds.origin.x;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    // Loop through each attachment behaviour and amend the center so that spring takes over to restore.
    for (UIAttachmentBehavior *attachment in [self currentAttachmentBehaviours]) {
        
        CGPoint anchorPoint = attachment.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.x - anchorPoint.x);
        CGFloat scrollResistance = distanceFromTouch / 1000.0;
        
        UICollectionViewLayoutAttributes *attributes = [attachment.items firstObject];
        CGPoint center = attributes.center;
        
        // Determine the veer offset.
        CGFloat veerOffset = floorf(scrollDelta * scrollResistance);
        veerOffset = MAX(10.0, veerOffset);
        // DLog(@"Veer Offset [%f]", veerOffset);
        
        // Amend the center of the attribute to veer.
        attributes.center = (CGPoint){ center.x + veerOffset, anchorPoint.y };
        
        [self.dynamicAnimator updateItemFromCurrentState:attributes];
    }
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    DLog();
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertedIndexPaths = [NSMutableArray array];
    self.deletedIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
        else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
            [self.deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates {
    DLog();
    [super finalizeCollectionViewUpdates];
    
    [self.insertedIndexPaths removeAllObjects];
    [self.deletedIndexPaths removeAllObjects];
    self.insertedIndexPaths = nil;
    self.deletedIndexPaths = nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    if (self.physicsEnabled) {
        [layoutAttributes addObjectsFromArray:[self.dynamicAnimator itemsInRect:rect]];
    } else {
        [layoutAttributes addObjectsFromArray:self.itemsLayoutAttributes];
    }
    
    // Cell returns kind of nil.
    NSArray *cellLayoutAttributes = [layoutAttributes select:^BOOL(UICollectionViewLayoutAttributes *attributes) {
        return (attributes.representedElementKind == nil);
    }];
    
    [self applyPagingEffects:cellLayoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.physicsEnabled) {
        return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    } else {
        return [self.indexPathItemAttributes objectForKey:indexPath];
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    initialAttributes.alpha = 1.0;
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == kMyBookSection) {
            
            // Inserted my book plops down.
            CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kBookScaleFactor, kBookScaleFactor, 0.0);
            initialAttributes.transform3D = scaleTransform;
            
        } else if (itemIndexPath.section == kFollowSection) {
            
            // Inserted followed book slides in.
            CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, 62.0, 0.0, 0.0);
            initialAttributes.transform3D = translateTransform;
        }
        
    }
    
    return initialAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    for (NSValue *anchorValue in self.anchorPoints) {
        CGPoint anchorPoint = [anchorValue CGPointValue];
        CGFloat itemHorizontalCenter = anchorPoint.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    return targetContentOffset;
}


- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = nil;
    
    // Custom deleted item.
    if ([self.deletedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == kMyBookSection) {
            
            // Deleted my book fades away.
            finalAttributes = [self layoutAttributesForMyBook];
            finalAttributes.alpha = 0.0;
            finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, kBookDeleteScaleFactor, kBookDeleteScaleFactor, 0.0);
            finalAttributes.transform3D = CATransform3DTranslate(finalAttributes.transform3D, 0.0, finalAttributes.frame.size.height, 0.0);
            
        } else if (itemIndexPath.section == kFollowSection) {
            
            // Deleted follow book fades away.
            finalAttributes = [self layoutAttributesForFollowBookAtIndex:itemIndexPath.item];
            
            if (self.editMode) {
                
                // Parting books to the side.
                finalAttributes.alpha = 0.0;
                finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, 1.0, 1.0, 0.0);
                finalAttributes.transform3D = CATransform3DTranslate(CATransform3DIdentity, 62.0, 0.0, 0.0);;
                
            } else {
                finalAttributes.alpha = 0.0;
                finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, kBookDeleteScaleFactor, kBookDeleteScaleFactor, 0.0);
                finalAttributes.transform3D = CATransform3DTranslate(finalAttributes.transform3D, 0.0, finalAttributes.frame.size.height, 0.0);
            }
            
        }
    }

    return finalAttributes;
}

#pragma mark - Properties

- (UIDynamicAnimator *)dynamicAnimator {
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

#pragma mark - Private methods

- (void)buildLayout:(BOOL)force {
    
    // If layout has already completed and not forced, then return immediately.
    if (!force && self.layoutCompleted) {
        return;
    }
    
    DLog(@"Building layout");
    self.anchorPoints = [NSMutableArray array];
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    // Reset all behaviours.
    [self.dynamicAnimator removeAllBehaviors];
    
    // Do we have my book?
    if ([self.collectionView numberOfItemsInSection:kMyBookSection] != 0) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForMyBook];
        
        [self applyAttachmentBehaviourToAttributes:attributes];
        [self.anchorPoints addObject:[NSValue valueWithCGPoint:attributes.center]];
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:attributes.indexPath];
    }
    
    // Middle gap/anchor.
    UICollectionViewLayoutAttributes *myBookAttributes = [self.itemsLayoutAttributes firstObject];
    CGPoint gapAnchor = (CGPoint){ myBookAttributes.center.x + kBookSize.width, myBookAttributes.center.y };
    [self.anchorPoints addObject:[NSValue valueWithCGPoint:gapAnchor]];
    
    // Do we have followed books?
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    for (NSInteger bookIndex = 0; bookIndex < numFollowBooks; bookIndex++) {
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForFollowBookAtIndex:bookIndex];
        [self applyAttachmentBehaviourToAttributes:attributes];
        [self.anchorPoints addObject:[NSValue valueWithCGPoint:attributes.center]];
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:attributes.indexPath];
    }
    
    // Apply collision.
    [self applyCollisionBehaviour:self.itemsLayoutAttributes];
    
    // Mark layout as completed.
    self.layoutCompleted = YES;
    
    // Inform delegate of updated layout.
    [self.delegate pagingLayoutDidUpdate];
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    [self applyScaling:layoutAttributes];
    [self applyPartingEffects:layoutAttributes];
    [self applyEditModeEffects:layoutAttributes];
}

- (void)applyScaling:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
        attributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
    }
}

- (void)applyPartingEffects:(NSArray *)layoutAttributes {
    
    CGFloat partDistance = 20.0;
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        CGPoint center = attributes.center;
        CGRect visibleRect = [self visibleFrame];
        CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
        
        if (ABS(distance) >= kBookSize.width && ABS(distance) < kBookSize.width * 2.0) {
            
            // If distance is less than two books away, then start the parting towards the edge.
            CGFloat normalizedDistance = (ABS(distance) - kBookSize.width) / kBookSize.width;
            CGFloat translateOffset = (1.0 - ABS(normalizedDistance)) * partDistance;
            if (distance > 0) {
                translateOffset *= -1;
            }
            
            attributes.transform3D = CATransform3DTranslate(attributes.transform3D, translateOffset, 0.0, 0.0);
            
        } else if (ABS(distance) < kBookSize.width) {
            
            // If distance is less than a book away, then revert the parting towards the center.
            CGFloat normalizedDistance = distance / kBookSize.width;
            CGFloat translateOffset = ABS(normalizedDistance) * partDistance;
            if (distance > 0) {
                translateOffset *= -1;
            }
            
            attributes.transform3D = CATransform3DTranslate(attributes.transform3D, translateOffset, 0.0, 0.0);
            
        }
        
    }
}

- (void)applyEditModeEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        if (self.editMode) {
            NSIndexPath *indexPath = attributes.indexPath;
            if (indexPath.section == kMyBookSection) {
                attributes.alpha = 1.0;
            } else if (indexPath.section == kFollowSection) {
                attributes.alpha = 0.0;
            }
        } else {
            attributes.alpha = 1.0;
        }
    }
}

- (CGFloat)scaleFactorForCenter:(CGPoint)center {
    CGRect visibleRect = [self visibleFrame];
    CGFloat minScaleFactor = 0.78;
    CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
    CGFloat normalizedDistance = distance / kBookSize.width;
    CGFloat scaleFactor = 0.0;
    
    if (ABS(distance) <= kBookSize.width) {
        scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - minScaleFactor));
    } else {
        scaleFactor = minScaleFactor;
    }
    
    // DLog(@"scaleFactor [%f]", scaleFactor);
    return scaleFactor;
}

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

- (void)applyAttachmentBehaviourToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if (!self.physicsEnabled) {
        return;
    }
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attributes
                                                             attachedToAnchor:attributes.center];
    spring.length = 0;
    spring.damping = 1.0;
    spring.frequency = 1.0;
    [self.dynamicAnimator addBehavior:spring];
}

- (NSArray *)currentAttachmentBehaviours {
    return [self.dynamicAnimator.behaviors select:^BOOL(UIDynamicBehavior *dynamicBehaviour) {
        return [dynamicBehaviour isKindOfClass:[UIAttachmentBehavior class]];
    }];
}

- (void)applyCollisionBehaviour:(NSArray *)items {
    if (!self.physicsEnabled) {
        return;
    }

    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:items];
    collision.collisionMode = UICollisionBehaviorModeItems;
    [self.dynamicAnimator addBehavior:collision];
}

@end
