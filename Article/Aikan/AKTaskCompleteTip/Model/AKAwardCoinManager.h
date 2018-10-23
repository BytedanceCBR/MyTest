//
//  AKAwardCoinTipManager.h
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#import <Foundation/Foundation.h>
#import "AKAwardCoinTipModel.h"
#import "TTActivity.h"
@interface AKAwardCoinManager : NSObject

+ (instancetype)shareInstance;

/**
 展示一个获得金币的弹窗，默认10金币，标题也是默认的

 @param view 需要展示的view，如果不传，则在window上展示
 @param tipType 决定弹窗的形态以及标题的内容，目前支持文章和视频
 */
+ (void)showAwardCoinTipInView:(UIView *)view
                       tipType:(AKAwardCoinTipType)tipType;


/**
 可以自定义金币数量，标题的弹窗

 @param view 需要展示的view，如果不传，则在window上展示
 @param tipType 决定弹窗的形态以及标题的内容，目前支持文章和视频
 @param coinNum 金币数量
 @param title 标题，如果是nil则使用默认
 */
+ (void)showAwardCoinTipInView:(UIView *)view
                       tipType:(AKAwardCoinTipType)tipType
                       coinNum:(NSInteger)coinNum
                         title:(NSString *)title;

+ (void)requestReadBounsWithGroupID:(NSString *)groupID
                     withExtraParam:(NSDictionary *)extParam
                         completion:(void (^)(NSInteger, NSString *,NSDictionary *))completion;

+ (void)requestShareBounsWithGroup:(NSString *)groupID
                          fromPush:(BOOL)fromPush
                        completion:(void(^)(NSString *, NSInteger))completion;
+ (BOOL)isShareTypeWithActivityType:(TTActivityType)type;
- (BOOL)checkIfNeedMonitorWithGroupID:(NSString *)groupID;
- (void)setHadReadWithGroupID:(NSString *)groupID;
@end
