//
//  TTVVideoDetailCommodityViewController.h
//  Article
//
//  Created by panxiang on 2017/10/26.
//

#import <UIKit/UIKit.h>
#import "TTVWhiteBoard.h"
#import "TTVPlayerControllerProtocol.h"
#import "TTVVideoPlayerStateStore.h"

@interface TTVVideoDetailCommodityViewController : UIViewController<TTVPlayerContext>
@property (nonatomic ,assign)CGFloat pgcHeight;
@property (nonatomic, strong) TTVWhiteBoard *whiteboard;
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@end

