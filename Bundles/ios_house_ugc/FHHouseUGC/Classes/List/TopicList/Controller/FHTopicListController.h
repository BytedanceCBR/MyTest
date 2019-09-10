//
//  FHTopicListController.h
//  小区话题列表页VC
//
//  Created by zhulijun on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHBaseViewController.h"
#import "FHTopicListModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHTopicListControllerDelegate <NSObject>
- (void)didSelectedHashtag:(FHTopicListResponseDataListModel *)hashtagModel;
@end

@interface FHTopicListController : FHBaseViewController
@property(nonatomic, weak, readonly) id<FHTopicListControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
