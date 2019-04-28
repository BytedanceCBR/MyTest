//
//  TTVCommodityView.h
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVVideoPlayerStateStore.h"

@class TTVPlayVideo;
@protocol TTVCommodityViewDelegate <NSObject>

- (void)commodityViewClosed;

@end

@class TTVPlayerView;
@interface TTVCommodityView : UIView<TTVPlayerContext>
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, weak) TTVPlayVideo *playVideo;
/**
 如果有playerStateStore,则内部计算,没有,则说明是没有播放器,使用外部赋值的数据
 */
@property (nonatomic, copy) NSString *position;
@property (nonatomic, weak) NSObject <TTVCommodityViewDelegate> *delegate;
- (void)setCommoditys:(NSArray *)commoditys;
- (void)closeCommodity;
- (void)showCommodity;
- (void)ttv_removeFromSuperview;
@end


