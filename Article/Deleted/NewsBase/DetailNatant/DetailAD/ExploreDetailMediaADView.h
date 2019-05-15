//
//  ExploreDetailMediaADView.h
//  Article
//
//  Created by admin on 16/5/31.
//
//

#import "ExploreDetailBaseADView.h"
#import "TTLabel.h"

/*
 5.6 文章详情页底部的广告位支持头条号推荐
https://wiki.bytedance.com/pages/viewpage.action?pageId=55125185
*/

@interface ExploreDetailMediaADView : ExploreDetailBaseADView

@property(nonatomic, strong) TTImageView   *imageView;
@property(nonatomic, strong) TTLabel *titleLabel;
@property(nonatomic, strong) SSThemedLabel *adLabel;
@property(nonatomic, strong) TTLabel *descLabel;

- (void)layout;
@end
