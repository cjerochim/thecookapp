//
//  FriendsStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 30/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "FriendsStoreCollectionViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "EventHelper.h"

@interface FriendsStoreCollectionViewController ()

@end

@implementation FriendsStoreCollectionViewController

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    if (friendsBook) {
        return YES;
    } else {
        return [super updateForFriendsBook:friendsBook];
    }
}

- (void)loadData {
    DLog();
    [CKBook friendsBooksForUser:[CKUser currentUser]
                         success:^(NSArray *featuredBooks) {
                             [self loadBooks:featuredBooks];
                         }
                         failure:^(NSError *error) {
                             DLog(@"Error: %@", [error localizedDescription]);
                         }];
}

- (UIView *)noDataView {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_library_nofriends.png"]];
}

- (BOOL)addMode {
    return YES;
}

@end
