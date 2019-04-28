//
//  TTAdDetailContainerView.h
//  Article
//
//  Created by SunJiangting on 17/7/06.
//
//

#import "ArticleDetailADModel.h"
#import "ExploreDetailBaseADView.h"
#import "TTAdDetailViewDefine.h"
#import "TTDetailNatantViewBase.h"
#import "TTAdDetailViewModel.h"

@interface TTAdDetailContainerView : TTDetailNatantViewBase <TTAdDetailADViewDelegate, TTDetailNatantViewBase>

- (nullable instancetype)initWithWidth:(CGFloat)width NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, nullable, readonly) NSArray<ArticleDetailADModel *> *adModels;
@property (nonatomic, weak, nullable) id<TTAdDetailContainerViewDelegate> delegate;
@property (nonatomic, strong, nullable) TTAdDetailViewModel *viewModel;

@end
