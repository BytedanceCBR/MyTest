//
//  TTVVideoDetailNatantADView.h
//  Article
//
//  Created by pei yun on 2017/5/23.
//
//

#import <TTThemed/SSThemed.h>
#import <TTVideoService/VideoInformation.pbobjc.h>
#import "UIScrollView+Impression.h"
#import "TTADEventTrackerEntity.h"
#import "TTVDetailContext.h"
#import "TTAdFeedDefine.h"

@protocol TTVVideoDetailNatantADViewDataProtocol <NSObject>

@property (nonatomic, strong, readonly) TTVADVideoInfo *adVideoInfo;
@property (nonatomic, strong, readonly) id<TTAdFeedModel> adModel;

@end

@interface TTVVideoDetailNatantADView : SSThemedView <TTImpressionViewProtocol,TTVDetailContext>

@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
@property (nonatomic, strong) id<TTVVideoDetailNatantADViewDataProtocol> article;
@property (nonatomic, copy) TTADEventTrackerEntity *(^getADEventTrackerEntity)();

@end
