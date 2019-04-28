//
//  TTDetailNatantRewardView.h
//  Article
//
//  Created by 刘廷勇 on 16/4/29.
//
//

#import "TTDetailNatantViewBase.h"
#import "TTDetailNatantRewardViewModel.h"
#import "TTDetailModel.h"

@class TTAlphaThemedButton;

typedef void(^RewardBlock)(void);

@interface TTDetailNatantRewardView : TTDetailNatantViewBase

@property (nonatomic, strong) TTDetailNatantRewardViewModel *viewModel;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) RewardBlock clickReportBlock;
@property (nonatomic, strong) NSString *goDetailLabel;//dislike埋点用

- (void)filterWordIsEmpty;

@end
