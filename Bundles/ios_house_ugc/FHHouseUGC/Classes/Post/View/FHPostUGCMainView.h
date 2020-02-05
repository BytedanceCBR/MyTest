//
//  FHPostUGCMainView.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHPostUGCMainViewDelegate <NSObject>

- (void)tagCloseButtonClicked;

@end

typedef NS_ENUM(NSUInteger, FHPostUGCMainViewType) {
    FHPostUGCMainViewType_Post,
    FHPostUGCMainViewType_Wenda
};

typedef NS_ENUM(NSUInteger, FHPostUGCTagType) {
    FHPostUGCTagType_Normal, // 正常圈子
    FHPostUGCTagType_HotTag, // 热门圈子标签
    FHPostUGCTagType_History, // 历史标签
};

#define INVALID_TAG_INDEX   -1
// 选择小区 类名懒得改了
@interface FHPostUGCMainView : UIControl

@property (nonatomic, weak) id<FHPostUGCMainViewDelegate> delegate;
@property (nonatomic, strong)   UIImageView       *rightImageView;
@property (nonatomic, copy)     NSString       *communityName;  // 小区名称
@property (nonatomic, copy)     NSString       *groupId;        // 圈子 id
@property (nonatomic, assign)   BOOL       followed;            // 是否已关注
@property (nonatomic, assign)   BOOL       hasValidData;        // 是否有效
@property (nonatomic, assign)   FHPostUGCTagType tagType;       // 标签类型
@property (nonatomic, assign)   NSInteger   tagIndex;       // 标签下标，用于反插

- (instancetype)initWithFrame:(CGRect)frame type:(FHPostUGCMainViewType)type;

@end

NS_ASSUME_NONNULL_END
