//
//  WDDiggButton.h
//  Article
//
//  Created by 张延晋 on 17/11/16.
//
//

#import "TTAlphaThemedButton.h"

typedef NS_ENUM(NSUInteger, WDDiggButtonClickType)
{
    WDDiggButtonClickTypeDigg,
    WDDiggButtonClickTypeAlreadyDigg,
};

typedef NS_ENUM(NSUInteger, WDDiggButtonDiggActionType) {
    WDDiggButtonDiggActionTypeDefault = 0,  //普通单次点赞
    WDDiggButtonDiggActionTypeMultDigg = 1, //多次点赞
};

typedef void(^WDDiggButtonClickBlock)(WDDiggButtonClickType type);
typedef BOOL(^WDDiggButtonShouldClickBlock)(void);

@interface WDDiggButton : TTAlphaThemedButton

+ (id)diggButton;

- (void)setDiggCount:(int64_t)diggCount;
- (void)setClickedBlock:(WDDiggButtonClickBlock)block;

@property (nonatomic, assign) BOOL manulSetSelectedEnabled;
@property (nonatomic, copy)   WDDiggButtonShouldClickBlock shouldClickBlock;
@property (nonatomic, assign) WDDiggButtonDiggActionType diggActionType;
@property (nonatomic, assign) CGFloat                    mutilDiggAngle;
@property (nonatomic, strong) NSValue                    *mutilDiggContentInset;

@end
