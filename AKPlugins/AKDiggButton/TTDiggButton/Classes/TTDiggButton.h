//
//  TTDiggButton.h
//  Article
//
//  Created by ZhangLeonardo on 15/8/11.
//
//

#import <TTUIWidget/TTAlphaThemedButton.h>

typedef NS_ENUM(NSUInteger, TTDiggButtonClickType) {
    TTDiggButtonClickTypeDigg,
    TTDiggButtonClickTypeAlreadyDigg,
};

typedef NS_ENUM(NSUInteger, TTDiggButtonStyleType) {
    TTDiggButtonStyleTypeDigitalOnly,   //顶组件样式1：仅有数字
    TTDiggButtonStyleTypeBoth,          //顶组件样式2：数字/文字
    TTDiggButtonStyleTypeBothSmall,     //顶组件样式2：数字/文字，小图icon
//    TTDiggButtonStyleTypeBuryDigitalOnly,//复用， 作为踩组件样式1：仅有数字
    TTDiggButtonStyleTypeBuryBoth,      //复用，  作为踩组件样式2：数字/文字
    TTDiggButtonStyleTypeImageOnly,          //顶组件新样式：仅图片， 大图icon
//    TTDiggButtonStyleTypeBuryImageOnly,      //踩组件新样式：仅图片，大图icon
    TTDiggButtonStyleTypeBigBoth,            //顶组件新样式：数字/文字，大图icon
    TTDiggButtonStyleTypeSmallImageOnly,      //顶组件新样式：仅图片，小图icon
    TTDiggButtonStyleTypeBigNumber,            //顶组件新样式：数字大号，大图
    TTDiggButtonStyleTypeCommentOnly
};

typedef NS_ENUM(NSUInteger, TTDiggButtonDiggActionType) {
    TTDiggButtonDiggActionTypeDefault = 0,  //普通单次点赞
    TTDiggButtonDiggActionTypeMultiDigg = 1, //多次点赞
};

typedef void(^TTDiggButtonClickBlock)(TTDiggButtonClickType type);
typedef BOOL(^TTDiggButtonShouldClickBlock)(void);

@interface TTDiggButton : TTAlphaThemedButton

+ (id)diggButton;
+ (id)diggButtonWithStyleType:(TTDiggButtonStyleType)styleType;

- (void)setDiggCount:(int64_t)diggCount;
- (void)setClickedBlock:(TTDiggButtonClickBlock)block;

@property (nonatomic, assign) BOOL manuallySetSelectedEnabled;
@property (nonatomic, copy) TTDiggButtonShouldClickBlock shouldClickBlock;
@property (nonatomic, assign) TTDiggButtonDiggActionType diggActionType;
@property (nonatomic, assign) CGFloat multiDiggAngle;
@property (nonatomic, strong) NSValue *multiDiggContentInset;

@end
