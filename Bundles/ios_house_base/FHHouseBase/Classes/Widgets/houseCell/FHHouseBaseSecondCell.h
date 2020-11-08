//
//  FHHouseBaseSecondCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/11/6.
//

#import "FHHouseBaseCell.h"
#import "FHCommonDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseBaseSecondCell : FHHouseBaseCell

- (CGFloat)contentSmallImageMaxWidth;

- (NSAttributedString *)originPriceAttr:(NSString *)originPrice;

- (CGFloat)contentSmallImageTagMaxWidth;

- (void)updateSamllTitlesLayout:(BOOL)showTags;

@property(nonatomic, strong) UIView *maskVRImageView;

@property(nonatomic, strong) UIButton *closeBtn; //x按钮

@property(nonatomic, strong) UILabel *statInfoLabel; //新房状态信息

@end

NS_ASSUME_NONNULL_END
