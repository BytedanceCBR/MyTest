//
//  ExploreAddEntryListViewController.h
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "SSViewControllerBase.h"

@class ExploreAddEntryListView;

@interface ExploreAddEntryListViewController : SSViewControllerBase

@property (nonatomic, strong) ExploreAddEntryListView *subscriptionListView;

- (instancetype)initWithShowGroupID:(NSString *)needShowGroupID;

@end
