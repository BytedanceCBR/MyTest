//
//  TTDetailNatantRelateReadPlainView.h
//  Article
//
//  Created by yuxin on 5/5/16.
//
//

#import "TTDetailNatantViewBase.h"
#import "TTDetailNatantRelateReadViewModel.h"

@interface TTDetailNatantRelateReadPlainView : TTDetailNatantViewBase

@property(nonatomic, assign) NSInteger index;

+ (nullable TTDetailNatantRelateReadPlainView *)genViewForModel:(nullable TTDetailNatantRelatedItemModel *)model
                                                          width:(float)width;

- (void)hideBottomLine:(BOOL)hide;

- (void)refreshFrame;

@end
