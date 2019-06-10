//
//  TTVCommodityButtonView.h
//  Article
//
//  Created by panxiang on 2017/10/23.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVVideoPlayerStateStore.h"

@class TTVCommodityEntity;
@protocol TTVCommodityButtonViewDelegate <NSObject>

- (void)ttv_clickCommodityButton;

@end

@interface TTVCommodityButtonView : UIView
@property (nonatomic ,weak)NSObject <TTVCommodityButtonViewDelegate> *delegate;
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;

- (void)ttv_showCommodityTrack;
@end
