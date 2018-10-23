//
//  TTVideoDetailADContainerView.h
//  Article
//
//  Created by yin on 16/9/29.
//
//

#import "ArticleDetailADModel.h"
#import "ExploreDetailBaseADView.h"
#import "TTAdDetailViewDefine.h"
#import "TTDetailNatantViewBase.h"
#import "TTAdDetailViewModel.h"

@interface TTVideoDetailADContainerView : TTDetailNatantViewBase <TTAdDetailADViewDelegate, TTDetailNatantViewBase>

- (nullable instancetype)initWithWidth:(CGFloat)width;

@property (nonatomic, copy, nullable) NSArray<ArticleDetailADModel *> *adModels;
@property (nonatomic, assign) BOOL isVideoAd;
@property (nonatomic, weak, nullable) __weak id<TTAdDetailContainerViewDelegate> delegate;
@property (nonatomic, strong, nullable) TTAdDetailViewModel *viewModel;

@end
