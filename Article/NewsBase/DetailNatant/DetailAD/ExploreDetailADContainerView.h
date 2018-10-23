//
//  ExploreDetailADContainerView.h
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ArticleDetailADModel.h"
#import "ExploreDetailBaseADView.h"
#import "TTAdDetailViewDefine.h"
#import "TTDetailNatantViewBase.h"
#import "TTAdDetailViewModel.h"

@interface ExploreDetailADContainerView : TTDetailNatantViewBase <TTAdDetailADViewDelegate, TTDetailNatantViewBase>

- (nullable instancetype)initWithWidth:(CGFloat)width NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, nullable) NSArray<ArticleDetailADModel *> *adModels;
@property (nonatomic, assign) BOOL isVideoAd;
@property (nonatomic, weak, nullable) id<TTAdDetailContainerViewDelegate> delegate;
@property (nonatomic, strong, nullable) TTAdDetailViewModel *viewModel;

@end

