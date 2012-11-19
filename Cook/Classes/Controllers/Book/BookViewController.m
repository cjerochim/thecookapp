//
//  BookViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookViewController.h"
#import "RecipeViewController.h"
#import "ViewHelper.h"
#import "ContentsPageViewController.h"
#import "CKRecipe.h"
#import "MRCEnumerable.h"
#import "CategoryPageViewController.h"
#import "RecipeViewController.h"
#import "MPFlipViewController.h"

@interface BookViewController () <BookViewDelegate, BookViewDataSource, MPFlipViewControllerDataSource, MPFlipViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) NSArray *recipes;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) NSMutableArray *categoryPageIndexes;
@property (nonatomic, assign) id<BookViewControllerDelegate> delegate;
@property (nonatomic, strong) RecipeViewController *recipeViewController;
@property (nonatomic, strong) ContentsPageViewController *contentsViewController;
@property (nonatomic, strong) CategoryPageViewController *categoryViewController;

@property (nonatomic, strong) MPFlipViewController *flipViewController;
@property (nonatomic, assign) NSInteger previousIndex;
@property (nonatomic, assign) NSInteger tentativeIndex;

@property (nonatomic, assign) NSUInteger currentCategoryIndex;

@end

@implementation BookViewController

#define kCategoryPageIndex  2

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initScreen];
    [self loadData];
}

#pragma mark - BookViewDelegate

- (void)bookViewCloseRequested {
    [self.delegate bookViewControllerCloseRequested];
}

-(void)contentViewRequested
{
    self.previousIndex = 2;
    [self.flipViewController gotoPreviousPage];
}

- (CGRect)bookViewBounds {
    return self.view.bounds;
}

- (UIEdgeInsets)bookViewInsets {
    return UIEdgeInsetsMake(20.0, 0.0, 10.0, 20.0);
}

- (BookViewController *)bookViewController {
    return self;
}

- (void)bookViewReloadRequested {
    DLog();
    self.recipes = nil;
    [self loadData];
}

#pragma mark - BookViewDataSource

- (CKBook *)currentBook {
    return self.book;
}

- (CKRecipe *)currentRecipe {
    return self.recipe;
}

- (NSInteger)numberOfPages {
    NSInteger numPages = 0;
    numPages += 1;                                  // Contents page.
    if ([self.recipes count] > 0) {
        numPages += [self.categoryNames count];        // Number of categories.
        numPages += [self.recipes count];           // Recipes page.
    }
    return numPages;
}

- (UIView *)viewForPageAtIndex:(NSInteger)pageIndex {
    UIViewController *viewController = [self viewControllerForPageIndex:pageIndex];
    return viewController.view;
}

- (UIViewController *)viewControllerForPageIndex:(NSInteger)pageIndex {
    UIViewController *viewController = nil;
    UIView *view = nil;
    
    if (pageIndex == 1) {
        
        // Contents page.
        view = self.contentsViewController.view;
        viewController = self.contentsViewController;
        [self.contentsViewController loadData];
        
    } else {
        
        NSInteger categoryIndex = [self categoryIndexForPageIndex:pageIndex];
        if (categoryIndex != -1) {
            
            // Category page.
            NSString *categoryName = [self.categoryNames objectAtIndex:categoryIndex];
            viewController = self.categoryViewController;
            [self.categoryViewController loadCategory:categoryName];
            [self.categoryViewController loadData];
            view = self.categoryViewController.view;
            
        } else {
            
            // Recipe page.
            categoryIndex = [self currentCategoryIndexForPageIndex:pageIndex];
            NSInteger categoryPageIndex = [[self.categoryPageIndexes objectAtIndex:categoryIndex] integerValue];
            NSInteger recipeIndex = pageIndex - categoryPageIndex - 1;
            NSString *categoryName = [self.categoryNames objectAtIndex:categoryIndex];
            NSArray *recipes = [self.categoryRecipes objectForKey:categoryName];
            CKRecipe *recipe = [recipes objectAtIndex:recipeIndex];
            self.recipe = recipe;
            self.recipeViewController.recipe = recipe;
            viewController = self.recipeViewController;
            view = self.recipeViewController.view;
        }
        
    }
    return viewController;
}

- (NSArray *)bookRecipes {
    return self.recipes;
}

-(NSArray *)bookCategoryNames {
    return self.categoryNames;
}

- (NSArray *)recipesForCategory:(NSString *)categoryName {
    NSArray *recipes = nil;
    NSUInteger categoryIndex = [self.categoryNames indexOfObject:categoryName];
    if (categoryIndex != NSNotFound) {
        recipes = [self.categoryRecipes objectForKey:categoryName];
    }
    return recipes;
}

- (NSInteger)currentPageNumber {
    return self.previousIndex;
}

- (NSString *)bookViewCurrentCategoryName {
    return [self.categoryNames objectAtIndex:self.currentCategoryIndex];
}

- (NSInteger)numRecipesInCategory:(NSString *)categoryName {
    NSInteger recipeCount = 0;
    NSInteger categoryIndex = [self.categoryNames findIndex:categoryName];
    if (categoryIndex != NSNotFound) {
        recipeCount = [[self.categoryRecipes objectForKey:categoryName] count];
        DLog(@"num recipes for %@ : %i", categoryName,recipeCount);
    }
    return recipeCount;
}

#pragma mark - MPFlipViewControllerDataSource methods

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	NSInteger index = self.previousIndex;
	index--;
	if (index < 1) {
		return nil; // reached beginning, don't wrap
    }
    
	self.tentativeIndex = index;
	return [self viewControllerForPageIndex:index];
}

- (UIViewController *)flipViewController:(MPFlipViewController *)flipViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
	NSInteger index = self.previousIndex;
	index++;
	if (index > [self numberOfPages]) {
		return nil; // reached end, don't wrap
    }
	self.tentativeIndex = index;
	return [self viewControllerForPageIndex:index];
}

#pragma mark - MPFlipViewControllerDelegate protocol

- (void)flipViewController:(MPFlipViewController *)flipViewController didFinishAnimating:(BOOL)finished
    previousViewController:(UIViewController *)previousViewController transitionCompleted:(BOOL)completed {
	if (completed) {
		self.previousIndex = self.tentativeIndex;
	}
}

- (MPFlipViewControllerOrientation)flipViewController:(MPFlipViewController *)flipViewController
                   orientationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return MPFlipViewControllerOrientationHorizontal;
}

#pragma mark - Private methods

- (ContentsPageViewController *)contentsViewController {
    if (!_contentsViewController) {
        _contentsViewController = [[ContentsPageViewController alloc] initWithBookViewDelegate:self dataSource:self withButtonStyle:NavigationButtonStyleWhite];
    }
    return _contentsViewController;
}

- (CategoryPageViewController *)categoryViewController {
    if (!_categoryViewController) {
        _categoryViewController = [[CategoryPageViewController alloc] initWithBookViewDelegate:self dataSource:self withButtonStyle:NavigationButtonStyleGray];
    }
    return _categoryViewController;
}

- (RecipeViewController *)recipeViewController
{
    if (!_recipeViewController) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
        _recipeViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
        _recipeViewController.delegate = self;
        _recipeViewController.dataSource = self;
    }
    return _recipeViewController;
}

-(void) initScreen
{
   self.view.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
   self.view.backgroundColor = [UIColor whiteColor];
   [self initFlipper];
}

- (void)initFlipper {
//    self.pageFlipper = [[CookPageFlipper alloc] initWithFrame:self.view.frame];
//    self.pageFlipper.dataSource = self;
//    [self.view addSubview:self.pageFlipper];
    
    self.previousIndex = 1;
    self.flipViewController = [[MPFlipViewController alloc] initWithOrientation:MPFlipViewControllerOrientationHorizontal];
    self.flipViewController.delegate = self;
    self.flipViewController.dataSource = self;
    self.flipViewController.view.frame = self.view.bounds;
	[self addChildViewController:self.flipViewController];
	[self.view addSubview:self.flipViewController.view];
	[self.flipViewController didMoveToParentViewController:self];
    [self.flipViewController setViewController:self.contentsViewController direction:MPFlipViewControllerDirectionForward animated:NO completion:nil];
	
	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
	self.view.gestureRecognizers = self.flipViewController.gestureRecognizers;
}

- (void)loadData {
    [self.book listRecipesSuccess:^(NSArray *recipes) {
        
        self.currentCategoryIndex = 0;
        self.categoryRecipes = [NSMutableDictionary dictionary];
        self.categoryNames = [NSMutableArray array];
        for (CKRecipe *recipe in recipes) {
            
            NSString *categoryName = recipe.category.name;
            DLog(@"category name: %@", categoryName);
            if (![self.categoryNames containsObject:categoryName]) {
                NSMutableArray *recipes = [NSMutableArray arrayWithObject:recipe];
                [self.categoryRecipes setObject:recipes forKey:categoryName];
                [self.categoryNames addObject:categoryName];
                DLog(@"Adding new category %@",categoryName);
            } else {
                NSMutableArray *recipes = [self.categoryRecipes objectForKey:categoryName];
                [recipes addObject:recipe];
                DLog(@"Adding recipe %@ to existing category %@",recipe.name, categoryName);
            }
        }
        
        // Assign category page indexes.
        self.categoryPageIndexes = [NSMutableArray arrayWithCapacity:[self.categoryRecipes count]];
        for (NSUInteger categoryIndex = 0; categoryIndex < [self.categoryRecipes count]; categoryIndex++) {
            if (categoryIndex > 0) {
                NSInteger previousCategoryIndex = [[self.categoryPageIndexes lastObject] integerValue];
                NSString *categoryName = [self.categoryNames objectAtIndex:categoryIndex - 1];
                NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
                [self.categoryPageIndexes addObject:[NSNumber numberWithInteger:previousCategoryIndex + [categoryRecipes count] + 1]];
            } else {
                [self.categoryPageIndexes addObject:[NSNumber numberWithInteger:kCategoryPageIndex]];
            }
        }
        
        // Set recipes - important for observe (TODO remove this).
        self.recipes = recipes;
        
        // Reload contents.
        [self.contentsViewController loadData];
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (NSInteger)categoryIndexForPageIndex:(NSUInteger)pageIndex {
    return [self.categoryPageIndexes findIndexWithBlock:^BOOL(NSNumber *pageIndexNumber) {
        return ([pageIndexNumber integerValue] == pageIndex);
    }];
}

- (NSInteger)currentCategoryIndexForPageIndex:(NSInteger)pageIndex {
    NSInteger categoryIndex = -1;
    if (pageIndex > kCategoryPageIndex) {
        
        for (NSInteger index = 0; index < [self.categoryPageIndexes count]; index++) {
            NSNumber *categoryPageIndex = [self.categoryPageIndexes objectAtIndex:index];
            if (pageIndex > [categoryPageIndex integerValue]) {
                
                // Candidate category index
                categoryIndex = index;
                
            } else {
                
                // We've found it before, break now.
                break;
            }
        }
    }
    
    return categoryIndex;
}

@end
