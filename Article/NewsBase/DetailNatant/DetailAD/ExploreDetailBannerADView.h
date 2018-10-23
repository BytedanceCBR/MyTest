//
//  ExploreDetailBannerADView.h
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ExploreDetailBaseADView.h"

@interface ExploreDetailBannerADView : ExploreDetailBaseADView

@property(nonatomic, strong) SSThemedView  *contentView;

@property(nonatomic, strong) TTImageView   *imageView;
@property(nonatomic, strong) SSThemedLabel *titleLabel;
@property(nonatomic, strong) SSThemedLabel *descLabel;
@property(nonatomic, strong) SSThemedLabel *adLabel;

@end
