//
//  CKNavigationController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNavigationController.h"

@interface CKNavigationController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CKNavigationController

- (id)initWithRootViewController:(UIViewController *)viewController {
    return [self initWithRootViewController:viewController delegate:nil];
}

- (id)initWithRootViewController:(UIViewController *)viewController delegate:(id<CKNavigationControllerDelegate>)delegate {
    if (self = [super init]) {
        
        // Sets myself on the viewController so it can call push/pops.
        if ([viewController conformsToProtocol:@protocol(CKNavigationControllerSupport)]) {
            [viewController performSelector:@selector(setCookNavigationController:) withObject:self];
        }
        
        self.viewControllers = [NSMutableArray arrayWithObject:viewController];
        
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    UIViewController *rootViewController = [self.viewControllers firstObject];
    rootViewController.view.frame = self.view.bounds;
    [self.view addSubview:rootViewController.view];
    
    // Inform view didAppear on all lifecycle events.
    if ([rootViewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
        [rootViewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(YES)];
    }
    if ([rootViewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
        [rootViewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(YES)];
    }
    if ([rootViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
        [rootViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
    }
    
    // Register left screen edge for shortcut to home.
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(screenEdgePanned:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:leftEdgeGesture];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController) {
        return;
    }
    
    if (animated && self.animating) {
        return;
    }
    
    // Sets myself on the viewController so it can call push/pops.
    if ([viewController conformsToProtocol:@protocol(CKNavigationControllerSupport)]) {
        [viewController performSelector:@selector(setCookNavigationController:) withObject:self];
    }
    
    // Get current viewController.
    UIViewController *currentViewController = [self currentViewController];
    
    if (animated) {
        
        self.animating = YES;
        
        // Prep the VC to be slid in from the right.
        viewController.view.frame = self.view.bounds;
        viewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
        [self.view addSubview:viewController.view];
        
        // Inform view will appear.
        if ([viewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
            [viewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(YES)];
        }
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             // Slide outgoing to the left.
                             currentViewController.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0);
                             
                             // Slide incoming from the right.
                             viewController.view.transform = CGAffineTransformIdentity;
                             
                             // Inform view appearing animating.
                             if ([viewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
                                 [viewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(YES)];
                             }
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Hide current one.
                             currentViewController.view.hidden = YES;
                             
                             // Add to list of pushed controllers.
                             [self.viewControllers addObject:viewController];
                             
                             // Inform view didAppear.
                             if ([viewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
                                 [viewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
                             }
                             
                             self.animating = NO;
                             
                         }];
        
    } else {
        
        // Hide current one.
        currentViewController.view.hidden = YES;
        
        // Just add to the view hierarchy.
        viewController.view.frame = self.view.bounds;
        [self.view addSubview:viewController.view];
        
        // Add to list of pushed controllers.
        [self.viewControllers addObject:viewController];
        
        // Inform view didAppear.
        if ([viewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
            [viewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(YES)];
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedViewController = [self currentViewController];
    UIViewController *previousViewController = [self previousViewController];
    
    // Return immediately if we're still animating.
    if (animated && self.animating) {
        return nil;
    }
    
    if (animated) {
        
        self.animating = YES;
        
        // Unhide previous view controller be slid back in.
        previousViewController.view.hidden = NO;

        // Inform view will disappear.
        if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewWillAppear:)]) {
            [poppedViewController performSelector:@selector(cookNavigationControllerViewWillAppear:) withObject:@(NO)];
        }
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             // Slide outgoing to the right.
                             poppedViewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
                             
                             // Slide incoming from the left.
                             previousViewController.view.transform = CGAffineTransformIdentity;
                             
                             // Inform view disappear animating.
                             if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewAppearing:)]) {
                                 [poppedViewController performSelector:@selector(cookNavigationControllerViewAppearing:) withObject:@(NO)];
                             }
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Inform view didAppear.
                             if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
                                 [poppedViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(NO)];
                             }
                             
                             // Remove the poppedViewController's view.
                             [poppedViewController.view removeFromSuperview];
                             
                             // Remove from list of pushed controllers.
                             [self.viewControllers removeLastObject];
                             
                             self.animating = NO;
                             
                         }];
        
    } else {
        
        // Inform view didAppear.
        if ([poppedViewController respondsToSelector:@selector(cookNavigationControllerViewDidAppear:)]) {
            [poppedViewController performSelector:@selector(cookNavigationControllerViewDidAppear:) withObject:@(NO)];
        }
        
        // Remove the poppedViewController's view.
        [poppedViewController.view removeFromSuperview];
        
        // Show the previous view controller.
        previousViewController.view.transform = CGAffineTransformIdentity;
        previousViewController.view.hidden = NO;
        
        // Remove from list of pushed controllers.
        [self.viewControllers removeLastObject];
        
    }
    
    return poppedViewController;
}

- (UIViewController *)currentViewController {
    return [self.viewControllers lastObject];
}

- (UIViewController *)topViewController {
    return [self.viewControllers firstObject];
}

- (BOOL)isTopViewController:(UIViewController *)viewController {
    return (viewController == [self topViewController]);
}

- (BOOL)isTop {
    return [self isTopViewController:[self currentViewController]];
}

#pragma mark - Private methods

- (UIViewController *)previousViewController {
    UIViewController *viewController = nil;
    
    if ([self.viewControllers count] > 1) {
        viewController = [self.viewControllers objectAtIndex:([self.viewControllers count] - 2)];
    }
    
    return viewController;
}

- (void)screenEdgePanned:(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    
    // If detected, then close the recipe.
    if (edgeGesture.state == UIGestureRecognizerStateBegan) {
        if ([self isTop]) {
            if ([self.delegate respondsToSelector:@selector(cookNavigationControllerCloseRequested)]) {
                [self.delegate cookNavigationControllerCloseRequested];
            }
        } else {
            [self popViewControllerAnimated:YES];
        }
    }
}

@end