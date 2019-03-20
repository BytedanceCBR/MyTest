//
//  FHSugHasSubscribeView.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/20.
//

#import <UIKit/UIKit.h>
#import "FHSugSubscribeModel.h"

NS_ASSUME_NONNULL_BEGIN

// 已订阅搜索
@interface FHSugHasSubscribeView : UIView

@property (nonatomic, assign)   CGFloat       hasSubscribeViewHeight; // 194

@property (nonatomic, assign)   NSInteger       totalCount;// 总个数
@property (nonatomic, strong , nullable) NSArray<FHSugSubscribeDataDataItemsModel> *subscribeItems;

@end

NS_ASSUME_NONNULL_END
