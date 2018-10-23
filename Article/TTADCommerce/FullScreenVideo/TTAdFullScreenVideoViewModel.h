//
//  TTAdFullScreenVideoViewModel.h
//  Article
//
//  Created by matrixzk on 28/07/2017.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TTAdFSVideoThirdPartyMonitorType) {
    TTAdFSVideoThirdPartyMonitorTypeEnter, // 进入落地页
    TTAdFSVideoThirdPartyMonitorTypeBreak, // 退到后台，push入新界面，退出落地页
    TTAdFSVideoThirdPartyMonitorTypePlay,  // 进入界面后视频开始播放
    TTAdFSVideoThirdPartyMonitorTypeClick  // 触发 ActionButton
};


@class TTRouteParamObj;
@interface TTAdFullScreenVideoViewModel : NSObject

- (instancetype)initWithParamObj:(TTRouteParamObj *)paramObj hostVC:(UIViewController *)hostVC;

- (UIView *)buildTopViewWithBackButtonPressedBlock:(void(^)(void))backActionBlock;
- (UIView *)buildBottomView;
- (CGFloat)heightOfBottomViewWith:(CGFloat)width;

- (void)eventTrackWithLabel:(NSString *)label;
- (void)eventTrackWithLabel:(NSString *)label extraDict:(NSDictionary *)dict;
- (void)eventTrack4ThirdPartyMonitorWithType:(TTAdFSVideoThirdPartyMonitorType)type;

@end
