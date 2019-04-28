 //
 //  ExploreDetailMixedADView.h
 //  Article
 //
 //  Created by SunJiangting on 15/7/22.
 //
 //
 
 #import "ExploreDetailBaseADView.h"
 
 /// 图文混合类型广告
 
 /// --------------------
 /// |                  |
 /// |                  |
 /// |                  |
 /// |                  |
 /// |                  |
 /// |                  |
 /// --------------------
 ///  这是一条广告
 
 @interface ExploreDetailMixedADView : ExploreDetailBaseADView
 
 @property(nonatomic, strong) TTImageView   *imageView;
 @property(nonatomic, strong) SSThemedLabel *titleLabel;
 @property(nonatomic, strong) SSThemedLabel *adLabel;
 @end
