//
//  FHPostUGCSelectedGroupHistoryView.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/8/11.
//

#import <UIKit/UIKit.h>
#import "FHUGCConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHPostUGCSelectedGroupHistoryViewDelegate <NSObject>
- (void)selectedHistoryGroup:(FHPostUGCSelectedGroupModel *)item;
@end

@interface FHPostUGCSelectedGroupHistoryView : UIView

@property (nonatomic, readonly) FHPostUGCSelectedGroupModel *model;

-(instancetype)initWithFrame:(CGRect)frame
                    delegate:(id<FHPostUGCSelectedGroupHistoryViewDelegate>) delegate
                historyModel:(FHPostUGCSelectedGroupModel *)model;
@end

NS_ASSUME_NONNULL_END
