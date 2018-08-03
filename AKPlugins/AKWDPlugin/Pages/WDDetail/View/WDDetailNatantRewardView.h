//
//  WDDetailNatantRewardView.h
//  Article
//
//  Created by 张延晋 on 17/11/16.
//
//

#import "WDDetailNatantViewBase.h"
#import "WDDetailNatantRewardViewModel.h"
#import "WDDetailModel.h"

@class TTAlphaThemedButton;

typedef void(^WDRewardBlock)(void);

@interface WDDetailNatantRewardView : WDDetailNatantViewBase

@property (nonatomic, strong) WDDetailNatantRewardViewModel *viewModel;
@property (nonatomic, strong) WDDetailModel *detailModel;
@property (nonatomic, strong) WDRewardBlock clickReportBlock;
@property (nonatomic, strong) NSString *goDetailLabel;//dislike埋点用

- (void)filterWordIsEmpty;

@end
