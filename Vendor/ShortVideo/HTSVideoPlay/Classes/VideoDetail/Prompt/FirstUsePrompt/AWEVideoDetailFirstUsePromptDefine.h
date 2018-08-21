//
//  AWEVideoDetailFirstUsePromptDefine.h
//  Pods
//
//  Created by Zuyang Kou on 01/08/2017.
//
//

#ifndef AWEVideoDetailFirstUsePromptDefine_h
#define AWEVideoDetailFirstUsePromptDefine_h

typedef NS_ENUM(NSUInteger, AWEPromotionDiretion) {
    AWEPromotionDiretionLeft,               //左右滑动切换视频
    AWEPromotionDiretionUpVideoSwitch,      //上下滑动切换视频
    AWEPromotionDiretionUpFloatingViewPop,  //上下滑动出浮层：评论/个人作品浮层
    AWEPromotionDiretionLeftEnterProfile,   //左滑进个人主页 
};

/* 这里的需求是 feed 流中的引导图和其他地方的分开考虑，也就是说，最多会在 feed 流里面出一次引导图，再在其他地方出一次引导图 
 * AWEPromotionCategoryDefault 是其他地方
 * AWEPromotionCategoryA 是 feed 流
 */
typedef enum : NSUInteger {
    AWEPromotionCategoryDefault,
    AWEPromotionCategoryA,
} AWEPromotionCategory;

typedef void (^DismissCompleteBlock)();

@protocol AWEVideoDetailFirstUsePromptViewController <NSObject>

@property (nonatomic, assign) AWEPromotionDiretion direction;
@property (nonatomic, copy) DismissCompleteBlock dismissCompleteBlock;

- (void)dismiss;

@end

#endif /* AWEVideoDetailFirstUsePromptDefine_h */
