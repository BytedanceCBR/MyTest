//
//  FHPostUGCMainView.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHPostUGCMainViewType) {
    FHPostUGCMainViewType_Post,
    FHPostUGCMainViewType_Wenda
};

// 选择小区 类名懒得改了
@interface FHPostUGCMainView : UIControl

@property (nonatomic, strong)   UIImageView       *rightImageView;
@property (nonatomic, copy)     NSString       *communityName;// 小区名称
@property (nonatomic, copy)     NSString       *groupId;// 圈子 id
@property (nonatomic, assign)   BOOL       followed; // 是否已关注
@property (nonatomic, assign)   BOOL       hasValidData;// 是否有效

- (instancetype)initWithFrame:(CGRect)frame type:(FHPostUGCMainViewType)type;

@end

NS_ASSUME_NONNULL_END
