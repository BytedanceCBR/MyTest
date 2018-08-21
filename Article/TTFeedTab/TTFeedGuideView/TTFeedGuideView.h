//
//  TTFeedGuideView.h
//  Article
//
//  Created by Chen Hong on 2017/7/18.
//
//

#import <UIKit/UIKit.h>
#import "TTGuideDispatchManager.h"
#import "TTBubbleView.h"

typedef NS_ENUM(NSUInteger, TTFeedGuideType) {
    TTFeedGuideTypeSearch,
    TTFeedGuideTypeDislike,
};

@interface TTFeedGuideTipModel : NSObject
@property(nonatomic, assign)    CGRect targetRect; // 目标frame
@property(nonatomic, assign)    CGFloat targetRectCornerRadius; // 目标frame圆角
@property(nonatomic, copy)      NSString *tip; // 气泡提示文案
@property(nonatomic, assign)    CGPoint arrowPoint; // 气泡箭头位置，相对与目标view左上角
@property(nonatomic, assign)    CGFloat radius; // 目标区域使用圆形的半径
@property(nonatomic, assign)    TTBubbleViewArrowDirection arrowDirection; // 气泡箭头方向
@end

@interface TTFeedGuideView : UIView<TTGuideProtocol>
- (void)addGuideItem:(TTFeedGuideTipModel *)item;
+ (void)configFromSettings:(NSDictionary *)setting;
+ (NSString *)textForType:(TTFeedGuideType)type; //引导文案
+ (BOOL)isFeedGuideTypeEnabled:(TTFeedGuideType)type;
- (void)dismiss;
@end
