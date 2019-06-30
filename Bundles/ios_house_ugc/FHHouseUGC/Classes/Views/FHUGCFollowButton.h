//
//  FHUGCFollowButton.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHUGCFollowButtonStyle) {
    FHUGCFollowButtonStyleBorder = 0,
    FHUGCFollowButtonStyleNoBorder,
};

// 关注按钮 已关注
@interface FHUGCFollowButton : UIButton

@property (nonatomic, assign) BOOL followed;// 默认是 NO
@property (nonatomic, strong) NSString *groupId;// 需要关注的小区id
/* page_type/ enter_from /enter_type /rank/log_pb */
@property (nonatomic, copy)     NSDictionary       *tracerDic;

@property (nonatomic, copy) void(^followedSuccess)(BOOL isSuccess,BOOL isFollow);

- (instancetype)initWithFrame:(CGRect)frame style:(FHUGCFollowButtonStyle)style;

@end

NS_ASSUME_NONNULL_END
