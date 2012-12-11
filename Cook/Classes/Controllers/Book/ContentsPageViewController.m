//
//  ContentsPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsPageViewController.h"
#import "ContentsCollectionViewController.h"
#import "UIFont+Cook.h"
#import "MRCEnumerable.h"
#import "CKRecipe.h"
#import "Category.h"
#import "RecipeLike.h"
#import "NewRecipeViewController.h"
#import "ContentsTableViewCell.h"
#import "ContentsPhotoCell.h"
#import "ViewHelper.h"
#import "Theme.h"
#import "FacebookUserView.h"

@interface ContentsPageViewController () <UITableViewDataSource, UITableViewDelegate, NewRecipeViewDelegate>

@property (nonatomic, strong) ContentsCollectionViewController *contentsCollectionViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIButton *likesButton;
@property (nonatomic, strong) FacebookUserView *facebookView;

@end

@implementation ContentsPageViewController

#pragma mark - PageViewController methods

#define kNameYOffset    150.0
#define kCategoryCellId @"CategoryCellId"

-(void)refreshData
{
    DLog();
    [self.tableView reloadData];
    [self refreshLikes];
    [self.contentsCollectionViewController loadRecipes:[self.dataSource bookRecipes]];
    [self showPageNumberAndHideLoading];
}

- (void)initPageView {
    [self initCollectionView];
    [self initTitleView];
    [self initFacebookView];
    [self initTableView];
    [self initCreateButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
    [self hidePageNumberAndDisplayLoading];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataSource bookCategoryNames] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryCellId forIndexPath:indexPath];
    NSString *categoryName = [[self.dataSource bookCategoryNames] objectAtIndex:indexPath.row];
    
    // Left item.
    cell.textLabel.font = [Theme defaultBoldFontWithSize:16.0];
    cell.textLabel.text = [categoryName uppercaseString];
    cell.textLabel.textColor = [Theme contentsItemColor];
    
    // Right page num.
    cell.detailTextLabel.font = [Theme defaultBoldFontWithSize:16.0];
    cell.detailTextLabel.textColor = [Theme defaultLabelColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.dataSource pageNumForCategoryName:categoryName]];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *categoryName = [[self.dataSource bookCategoryNames] objectAtIndex:indexPath.row];
    NSUInteger requestedPageIndex = [self.dataSource pageNumForCategoryName:categoryName];
    [self.delegate requestedPageIndex:requestedPageIndex];
}

#pragma mark - NewRecipeViewDelegate methods

- (void)closeRequested {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recipeCreated {
    [self.delegate bookViewReloadRequested];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)initTitleView {
    
    CKBook *book = [self.dataSource currentBook];
    NSString *title = [book.name uppercaseString];
    UIFont *font = [Theme defaultFontWithSize:40.0];
    CGSize size = [title sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + floorf((availableWidth - size.width) / 2.0),
                                                                   kNameYOffset,
                                                                   size.width,
                                                                   size.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = font;
    nameLabel.textColor = [Theme contentsTitleColor];
    nameLabel.shadowColor = [UIColor whiteColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.text = title;
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;
}

- (void)initFacebookView {
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    FacebookUserView *facebookView = [[FacebookUserView alloc] initWithFrame:CGRectZero];
    [facebookView setUser:[[self.dataSource currentBook] user]];
    facebookView.frame = CGRectMake(xOffset + floorf((availableWidth - facebookView.frame.size.width) / 2.0) - 20.0,
                                    self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height,
                                    facebookView.frame.size.width,
                                    facebookView.frame.size.height);
    [self.view addSubview:facebookView];
    self.facebookView = facebookView;
}

- (void)initTableView {
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    UIEdgeInsets tableInsets = UIEdgeInsetsMake(20.0, 150.0, 50.0, 100.0);
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(xOffset + tableInsets.left,
                                                                           self.facebookView.frame.origin.y + self.facebookView.frame.size.height + tableInsets.top,
                                                                           350.0,
                                                                           self.view.bounds.size.height - tableInsets.top - tableInsets.bottom)
                                                           style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView registerClass:[ContentsTableViewCell class] forCellReuseIdentifier:kCategoryCellId];
    
    [self initTableFooter];
    
}

- (void)initCollectionView {
    ContentsCollectionViewController *collectionViewController  = [[ContentsCollectionViewController alloc] init];
    collectionViewController.view.frame = CGRectMake(0.0,
                                                     0.0,
                                                     collectionViewController.view.frame.size.width,
                                                     self.view.bounds.size.height);
    collectionViewController.bookViewDataSource = self.dataSource;
    collectionViewController.bookViewDelegate = self.delegate;
    [self.view addSubview:collectionViewController.view];
    self.contentsCollectionViewController = collectionViewController;
}

- (void)initCreateButton {
    UIButton *createButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_addbook.png"]
                                                  target:self selector:@selector(createTapped:)];
    [createButton setFrame:CGRectMake(self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width - floorf(createButton.frame.size.width / 2.0),
                                      self.contentsCollectionViewController.view.frame.origin.y + floorf(([ContentsPhotoCell midSize].height - createButton.frame.size.width) / 2.0),
                                      createButton.frame.size.width, createButton.frame.size.height)];
    [self.view addSubview:createButton];
}

-(void)initTableFooter {
    //add a footer for likes
    self.likesButton = [ViewHelper buttonWithImagePrefix:@"cook_book_icon_like" target:self selector:@selector(likesButtonTapped:)];

    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, self.likesButton.frame.size.height+20.0f)];

    self.likesButton.frame = CGRectMake(floorf(0.5*(self.tableView.frame.size.width - self.likesButton.frame.size.width)), 0.0f, self.likesButton.frame.size.width, self.likesButton.frame.size.height);

    self.likesButton.hidden = YES;
    self.likesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, footerView.frame.size.height-20.0f, self.tableView.frame.size.width, 20.0f)];
    self.likesLabel.textAlignment = NSTextAlignmentCenter;
    self.likesLabel.font = [Theme defaultBoldFontWithSize:16.0f];
    self.likesLabel.textColor = [Theme contentsItemColor];
    
    [footerView addSubview:self.likesLabel];
    [footerView addSubview:self.likesButton];
    
    self.tableView.tableFooterView = footerView;

}

- (void)createTapped:(id)sender {
    DLog();
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    NewRecipeViewController *newRecipeViewVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewRecipeViewController"];
    newRecipeViewVC.recipeViewDelegate = self;
    newRecipeViewVC.book = [self.dataSource currentBook];
    [self presentViewController:newRecipeViewVC animated:YES completion:nil];
}

-(void)refreshLikes
{
    [RecipeLike fetchRecipeLikesForUser:[CKUser currentUser] withSuccess:^(NSArray *results) {
        self.likesLabel.text = [NSString stringWithFormat:@"%d LIKES",[results count]];
        self.likesButton.hidden = NO;
    } failure:^(NSError *error) {
        DLog(@"fetch recipe likes for user returned an error: %@", [error description]);
    }];
}

#pragma mark - Action buttons
-(void) likesButtonTapped:(UIButton*)likesButton
{
    
}
@end
