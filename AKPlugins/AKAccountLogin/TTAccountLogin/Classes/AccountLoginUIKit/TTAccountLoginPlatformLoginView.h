//
//  TTAccountLoginPlatformLoginView.h
//  TTAccountLogin
//
//  Created by huic on 16/3/1.
//
//

#import <SSThemed.h>
#import "TTAccountLoginDefine.h"



/**
 *  TTAccountLoginPlatformLoginViewDelegate 代理传递点击第三方登录事件
 */
@protocol TTAccountLoginPlatformLoginViewDelegate <NSObject>
- (void)loginPlatform:(NSString *)keyName;
@end



@interface TTAccountLoginPlatformLoginView : SSThemedView

/**
 Delegate
 */
@property (nonatomic, weak) NSObject<TTAccountLoginPlatformLoginViewDelegate> *delegate;

- (instancetype)initWithFrame:(CGRect)frame
                platformTypes:(TTAccountLoginPlatformType)types
            excludedPlatforms:(NSArray<NSString *> *)platformsNames;

/**
 判断平台是否展示
 */
- (BOOL)isShowingForPlatform:(NSString *)platformName;


@end
