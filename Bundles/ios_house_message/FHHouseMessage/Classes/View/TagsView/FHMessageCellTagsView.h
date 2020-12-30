//
//  FHMessageCellTagsView.h
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import <UIKit/UIKit.h>
#import "FHMessageCellTagModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageCellTagsView : UIView
@property (nonatomic, assign) BOOL isPassthrough; // 点击事件是否透传
- (void)updateWithTags:(nullable NSArray<FHMessageCellTagModel *> *)tags;
@end

NS_ASSUME_NONNULL_END
