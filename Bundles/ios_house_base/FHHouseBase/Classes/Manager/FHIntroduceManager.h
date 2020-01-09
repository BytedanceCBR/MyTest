//
//  FHIntroduceManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 首次安装或者升级安装引导介绍页 管理器
 *
 * 负责管理引导页的显示和隐藏
 */
@interface FHIntroduceManager : NSObject

+ (instancetype)sharedInstance;
//显示
- (void)showIntroduceView:(UIView *)keyWindow;
//隐藏
- (void)hideIntroduceView;
//是否正在显示中
@property (nonatomic , assign, readonly) BOOL isShowing;
//是否已经显示过，目前首次安装或者升级安装只显示一次
@property (nonatomic , assign) BOOL alreadyShow;

@end

NS_ASSUME_NONNULL_END
