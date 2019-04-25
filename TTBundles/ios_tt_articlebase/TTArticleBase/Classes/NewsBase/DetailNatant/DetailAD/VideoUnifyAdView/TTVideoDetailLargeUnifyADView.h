//
//  TTVideoDetailLargeUnifyADView.h
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailMixedLargePicADView.h"

extern CGFloat imageFitHeight(ArticleDetailADModel *adModel, CGFloat width);

@interface TTVideoDetailLargeUnifyADView : ExploreVideoDetailMixedLargePicADView

@property (nonatomic, strong) TTAlphaThemedButton *actionButton;

@end
