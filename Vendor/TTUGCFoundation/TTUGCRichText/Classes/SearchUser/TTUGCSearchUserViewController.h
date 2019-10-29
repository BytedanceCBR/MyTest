//
//  TTUGCSearchUserViewController.h
//  Article
//  at 功能搜索用户页
//
//  Created by Jiyee Sheng on 05/09/2017.
//
//



#import "SSViewControllerBase.h"
#import "FRApiModel.h"

@protocol TTUGCSearchUserTableViewDelegate <NSObject>

@optional

- (void)searchUserTableViewWillDismiss;
- (void)searchUserTableViewDidDismiss;
- (void)searchUserTableViewDidSelectedUser:(FRPublishPostSearchUserStructModel *)userModel;

@end


@interface TTUGCSearchUserViewController : SSViewControllerBase

@property (nonatomic, weak) id <TTUGCSearchUserTableViewDelegate> delegate;

@end
