//
//  FHHouseDetailHeaderMoreStateView.h
//  Pods
//
//  Created by bytedance on 2020/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHHouseDetailHeaderMoreState) {
    FHHouseDetailHeaderMoreStateBegin = 0, //查看更多
    FHHouseDetailHeaderMoreStateRelease = 1 //释放查看
};

@interface FHHouseDetailHeaderMoreStateView : UIView

@property (nonatomic, assign) FHHouseDetailHeaderMoreState moreState;

@end

NS_ASSUME_NONNULL_END
