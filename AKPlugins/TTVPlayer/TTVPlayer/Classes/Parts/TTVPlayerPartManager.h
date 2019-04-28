//
//  TTVPlayerPartManager.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/9.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerDefine.h"
#import "TTVReduxKit.h"
#import "TTVPlayerContextNew.h"
#import "TTVPlayerPartProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 管理 part：解析配置文件、添加和移除 part、part 中所有 view 的add、layout
 可以根据配置文件动态添加 part
 */
@interface TTVPlayerPartManager : NSObject<TTVReduxStateObserver, TTVPlayerContextNew, TTVPartManagerProtocol>
@property (nonatomic, assign) BOOL viewDidLoaded;

#pragma mark - config

/**
 设置播放器的 configData，会自动合并多个 config

 @param configData 播放器 configDic
 */
- (void)setPlayerConfigData:(NSDictionary * _Nonnull)configData;

- (void)viewDidLoad:(TTVPlayer *)playerVC;
- (void)viewDidLayoutSubviews:(TTVPlayer *)playerVC;


@end

NS_ASSUME_NONNULL_END
