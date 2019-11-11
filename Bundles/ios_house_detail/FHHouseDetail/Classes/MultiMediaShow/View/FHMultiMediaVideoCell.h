//
//  FHMultiMediaVideoCell.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMultiMediaVideoCell : FHMultiMediaBaseCell

@property(nonatomic, strong) UIView *playerView;

- (void)showCoverView;

@end

NS_ASSUME_NONNULL_END
