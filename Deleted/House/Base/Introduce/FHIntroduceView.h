//
//  FHIntroduceView.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <UIKit/UIKit.h>
#import <FHIntroduceModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHIntroduceView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(FHIntroduceModel *)model;

- (void)addIntroductionShowLog;

@end

NS_ASSUME_NONNULL_END
