//
//  FHHouseNewCardView.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseNewCardView : FHHouseNewComponentView

- (instancetype)initWithFrame:(CGRect)frame leftMargin:(CGFloat)left rightMargin:(CGFloat)right;

- (void)resumeVRIcon;

- (void)refreshOpacityWithData:(id)viewModel;

@end

NS_ASSUME_NONNULL_END
