//
//  IngredientsView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsView.h"
#import "Theme.h"
#import "ViewHelper.h"
#import "Ingredient.h"
#import "IngredientTableViewCell.h"
#import "NSArray+Enumerable.h"

#define kIngredientCellTag 112233
#define kIngredientTableViewCellIdentifier @"IngredientTableViewCell"

@interface IngredientsView()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>
@property(nonatomic,strong) UILabel *ingredientsLabel;
@property(nonatomic,strong) UIScrollView *ingredientsScrollView;
@property(nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *backgroundEditImageView;
@end

@implementation IngredientsView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.ingredientsLabel.hidden = editable;
    [self.tableView reloadData];
    self.tableView.hidden = !editable;
    self.backgroundEditImageView.hidden = !editable;
}

#pragma mark - Private methods
//overridden
-(void)configViews
{
    self.ingredientsScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);

    CGSize maxSize = CGSizeMake(190.0f, CGFLOAT_MAX);
    self.ingredientsLabel.text = [self stringFromIngredients];
    CGSize requiredSize = [self.ingredientsLabel.text sizeWithFont:self.ingredientsLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    self.ingredientsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
    [ViewHelper adjustScrollContentSize:self.ingredientsScrollView forHeight:requiredSize.height];
}

//overridden
-(void) styleViews
{
    self.ingredientsLabel.font = [Theme defaultLabelFont];
    self.ingredientsLabel.backgroundColor = [UIColor clearColor];
    self.ingredientsLabel.textColor = [Theme ingredientsLabelColor];
}

-(UILabel *)ingredientsLabel
{
    if (!_ingredientsLabel) {
        _ingredientsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _ingredientsLabel.numberOfLines = 0;
        [self.ingredientsScrollView addSubview:_ingredientsLabel];
    }
    
    return _ingredientsLabel;
}

-(UIScrollView *)ingredientsScrollView
{
    if (!_ingredientsScrollView) {
        _ingredientsScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _ingredientsScrollView.scrollEnabled = YES;
        [self addSubview:_ingredientsScrollView];
    }
    return _ingredientsScrollView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.hidden = YES;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kIngredientTableViewCellIdentifier];
        [self addSubview:_tableView];
    }
    return _tableView;
}

-(UIImageView *)backgroundEditImageView
{
    if (!_backgroundEditImageView) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];
        _backgroundEditImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        _backgroundEditImageView.hidden = YES;
        _backgroundEditImageView.image = backgroundImage;
        [self insertSubview:_backgroundEditImageView atIndex:0];
    }
    return _backgroundEditImageView;
}

-(void) adjustScrollContentSizeToHeight:(float)height
{
    self.ingredientsScrollView.contentSize = height > self.ingredientsScrollView.frame.size.height ?
        CGSizeMake(self.ingredientsScrollView.frame.size.width, height) :
    CGSizeMake(self.ingredientsScrollView.frame.size.width, self.ingredientsScrollView.frame.size.height);
}

-(NSString*)stringFromIngredients
{
    NSMutableString *mutableIngredientString = [[NSMutableString alloc]init];
    [self.ingredients each:^(Ingredient *ingredient) {
        [mutableIngredientString appendFormat:@"%@\n",ingredient.name];
    }];
    
    return [NSString stringWithString:mutableIngredientString];
}
#pragma mark - UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseCellID = kIngredientTableViewCellIdentifier;
    IngredientTableViewCell *cell = (IngredientTableViewCell*) [tableView dequeueReusableCellWithIdentifier:reuseCellID];
    Ingredient *ingredient = [self.ingredients objectAtIndex:indexPath.row];
    [cell setIngredient:ingredient forRow:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog();
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *parentView = [textField superview];
    IngredientTableViewCell *cell = (IngredientTableViewCell*)[parentView superview];
    Ingredient *ingredient = [self.ingredients objectAtIndex:cell.ingredientIndex];
    ingredient.name = textField.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
