//
//  TTVPlayerControlTipView.h
//  Article
//
//  Created by panxiang on 2017/5/16.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerTipFinished.h"
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerControllerState.h"
#import "TTVPlayerControllerProtocol.h"
#import "TTVPlayerTipCreator.h"

@interface TTVPlayerControlTipView : UIView<TTVPlayerControlTipView ,TTVPlayerContext>
@property(nonatomic, assign)TTVPlayerControlTipViewType tipType;
@property(nonatomic, assign)BOOL forbidLayout;
@property (nonatomic, strong ,readonly)UIView <TTVPlayerTipRetry> *retryView;
@property (nonatomic, strong ,readonly)UIView <TTVPlayerTipLoading> *loadingView;
@property (nonatomic, strong ,readonly)UIView <TTVPlayerTipFinished>  *finishedView;
@property (nonatomic, assign) CGRect superViewFrame;//适配X使用
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
- (void)createViewsWithCreator:(id <TTVPlayerTipCreator>)tipCreator;
@end

