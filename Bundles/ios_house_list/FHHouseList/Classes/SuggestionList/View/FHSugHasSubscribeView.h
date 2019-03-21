//
//  FHSugHasSubscribeView.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/20.
//

#import <UIKit/UIKit.h>
#import "FHSugSubscribeModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FHSugHasSubscribeItemClick)(FHSugSubscribeDataDataItemsModel *model);


// 已订阅搜索
@interface FHSugHasSubscribeView : UIView

@property (nonatomic, assign)   CGFloat       hasSubscribeViewHeight; // 194
@property (nonatomic, copy)     FHSugHasSubscribeItemClick       clickBlk;
@property (nonatomic, copy)     dispatch_block_t       clickHeader;
@property (nonatomic, assign)   NSInteger       totalCount;// 总个数
@property (nonatomic, strong , nullable) NSArray<FHSugSubscribeDataDataItemsModel> *subscribeItems;

@end

@interface FHSubscribeView : UIControl

@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *sugLabel;
@property (nonatomic, assign)   BOOL       isValid;

@end

NS_ASSUME_NONNULL_END
