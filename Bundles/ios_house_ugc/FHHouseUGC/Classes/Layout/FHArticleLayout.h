//
//  FHArticleLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHBaseLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHArticleLayout : FHBaseLayout

@property(nonatomic ,strong) FHLayoutItem *contentLabelLayout;
@property(nonatomic ,strong) FHLayoutItem *singleImageViewLayout;
@property(nonatomic ,strong) FHLayoutItem *imageViewContainerLayout;
@property(nonatomic ,strong) FHLayoutItem *bottomViewLayout;

@property(nonatomic ,strong) NSArray *imageLayouts;

@end

NS_ASSUME_NONNULL_END
