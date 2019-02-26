//
//  TTVBasePlayVideo.h
//  Article
//
//  Created by panxiang on 2017/5/11.
//
//

#import <Foundation/Foundation.h>
#import "TTVBasePlayerModel.h"
#import "TTVDemanderPlayerTracker.h"
#import "TTVPlayerOrientation.h"
#import "TTMovieStore.h"
#import "TTVBaseDemandPlayer.h"

//使用说明:
/*
 1.playerModel的数据要在TTVBasePlayVideo初始化的时候传入,后期更改playerModel的属性没有任何作用.
 调用player的- (void)registerPart:(NSObject <TTVPlayerContext> *)part 方法,然后实现自己的埋点.任何其他功能
 模块的嵌入都是通过这种方式接入.TTVPlayerContext协议中有播放器中各种状态以及event
 3.如果在当前播放器中,直接播放下一个视频,调用创建一个新的playerModel 然后调用resetPlayerModel方法.
 4.有定制化UI需求,实现playerModel以下属性即可
 tip工厂  默认 TTVPlayerTipCreator
 @property(nonatomic, strong)id <TTVPlayerTipCreator> tipCreator;
 自定义 播放器界面底部工具栏 bottomBarView
 @property(nonatomic, strong)UIView <TTVPlayerControlBottomView> *bottomBarView;
 自定义整个播放器控制界面
 @property(nonatomic, strong)UIView <TTVPlayerViewControlView ,TTVPlayerContext> *controlView;
 */

@class TTVDemanderTrackerManager;
typedef void(^TTVStopFinished)(void);
@interface TTVBasePlayVideo : UIView<TTMovieStoreAction>
@property (nonatomic, strong ,readonly) TTVBaseDemandPlayer *player;
@property (nonatomic, strong ,readonly) TTVBasePlayerModel *playerModel;
@property (nonatomic, strong ,readonly) TTVDemanderTrackerManager *commonTracker;//通用的tracker
- (instancetype)initWithFrame:(CGRect)frame playerModel:(TTVBasePlayerModel *)playerModel;
/**
 切换下一个视频的时候,重置播放器环境数据使用.
 */
- (void)resetPlayerModel:(TTVBasePlayerModel *)playerModel;
/**
 播放器封面图,可以转化为TTImageInfosModel的videoLargeImageDict,如果非TTImageInfosModel类型的model.
 使用替换 [self.player setLogoImageView:_logoImageView];
 */
- (void)setVideoLargeImageDict:(NSDictionary *)videoLargeImageDict;
- (void)setVideoLargeImageUrl:(NSString *)imageUrl;

/**
 移除所有的正在播放的播放器
 */
+ (void)removeAll;
/**
 移除所有的正在播放的播放器,除了传入的播放器.
 */
+ (void)removeExcept:(UIView <TTMovieStoreAction> *)video;

- (void)stopWithFinishedBlock:(TTVStopFinished)finishedBlock;
+ (TTVBasePlayVideo *)currentPlayingPlayVideo;

@end
