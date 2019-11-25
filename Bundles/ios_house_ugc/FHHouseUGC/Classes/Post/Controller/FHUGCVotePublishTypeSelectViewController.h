//
//  FHUGCVotePublishTypeSelectViewController.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/14.
//

#import "FHBaseViewController.h"
#import <FHUGCVotePublishModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVotePublishVoteTypeModel: NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) VoteType type;
@end

@interface FHUGCVotePublishTypeSelectViewController : FHBaseViewController

@end

NS_ASSUME_NONNULL_END
