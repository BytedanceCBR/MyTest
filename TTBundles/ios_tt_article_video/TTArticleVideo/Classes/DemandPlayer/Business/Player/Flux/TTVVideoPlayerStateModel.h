//
//  TTVPlayerStateModel.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
#import "TTVVideoPlayerModel.h"
#import "TTVPlayerStateModel.h"

@class TTVCommodityEntity;
@interface TTVVideoPlayerStateModel : TTVPlayerStateModel

//外部传入的参数,统计/控制信息需要.
@property (nonatomic, strong) TTVVideoPlayerModel *playerModel;

/**
 是否已经显示过贴片广告（用于限制原视频贴片广告的出现次数）
 */
@property(nonatomic, assign)BOOL pasterAdShowed;

/**
 是否正在展示贴片广告
 */
@property(nonatomic, assign)BOOL pasterADIsPlaying;

/**
 贴片广告是否开启转屏（用于屏蔽跳转落地页后贴片的转屏）
 */
@property(nonatomic, assign)BOOL pastarADEnableRotate;

/**
 贴片广告数据预取数据有效(目前主要用于判断原视频播放完成后是否退出全屏)
 */
@property(nonatomic, assign)BOOL pasterADPreFetchValid;

/**
 是否已经显示过贴片广告（用于限制原视频贴片广告的出现次数）
 */
@property(nonatomic, assign)BOOL midAdShowed;

/**
 是否正在展示贴片广告
 */
@property(nonatomic, assign)BOOL midADIsPlaying;

/**
 是否正在展示角标广告
 */
@property(nonatomic, assign)BOOL iconADIsPlaying;

/**
 特卖商品,当前是否显示状态,如果显示,进入详情页就不继续播放视频了.
 */
@property(nonatomic, assign)BOOL isCommodityViewShow;

/**
 播放器中特卖入口显示 隐藏
 */
@property(nonatomic, assign)BOOL isCommodityButtonShow;

///**
// 特卖商品入口button,点击后显示所有的特卖商品
// */
//@property(nonatomic, assign)BOOL isCommodityButtonShow;

@property(nonatomic, strong)NSArray <TTVCommodityEntity *> *commodityEngitys;


@end

