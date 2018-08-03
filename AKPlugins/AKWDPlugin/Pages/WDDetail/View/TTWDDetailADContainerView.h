//
//  TTWDDetailADContainerView.h
//  Article
//
//  Created by SunJiangting on 17/7/06.
//
//

#import "TTAdDetailViewDefine.h"
#import "WDDetailNatantViewBase.h"
#import "TTAdDetailViewModel.h"

@class ArticleDetailADModel;

@interface TTWDDetailADContainerView : WDDetailNatantViewBase <TTAdDetailADViewDelegate, WDDetailNatantViewBase, TTAdDetailContainerView>

- (nullable instancetype)initWithWidth:(CGFloat)width NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, nullable, readonly) NSArray<ArticleDetailADModel *> *adModels;
@property (nonatomic, weak, nullable) id<TTAdDetailContainerViewDelegate> delegate;
@property (nonatomic, strong, nullable) TTAdDetailViewModel *viewModel;

@end

