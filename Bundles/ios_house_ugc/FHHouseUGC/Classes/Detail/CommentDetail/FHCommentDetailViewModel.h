//
//  FHCommentDetailViewModel.h
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import <Foundation/Foundation.h>
#import "FHCommentDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommentDetailViewModel : NSObject

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView;

- (void)startLoadData;

@property (nonatomic, copy)     NSString       *comment_id;

@end

NS_ASSUME_NONNULL_END
