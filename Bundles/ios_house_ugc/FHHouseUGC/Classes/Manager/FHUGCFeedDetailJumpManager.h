//
//  FHUGCFeedDetailJumpManager.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/5/9.
//

#import <Foundation/Foundation.h>
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCFeedDetailJumpManager : NSObject

@property(nonatomic , strong) FHUGCBaseCell *currentCell;
@property(nonatomic , assign) NSInteger refer;

//进入feed详情页
- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel
         showComment:(BOOL)showComment
           enterType:(NSString *)enterType;

//需要传入额外字段
- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel
         showComment:(BOOL)showComment
           enterType:(NSString *)enterType
            extraDic:(nullable NSDictionary *)extraDic;

//进入圈子详情页
- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
