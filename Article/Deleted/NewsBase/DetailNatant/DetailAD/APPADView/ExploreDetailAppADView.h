//
//  ExploreDetailAppADView.h
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ExploreDetailBaseADView.h"

@interface ExploreDetailAppADView : ExploreDetailBaseADView

@property(nonatomic, strong) TTImageView    *imageView;
@property(nonatomic, strong) SSThemedLabel  *nameLabel;
@property(nonatomic, retain) SSThemedLabel  *infoLabel;
@property(nonatomic, retain) SSThemedButton *downloadButton;
@property(nonatomic, retain) SSThemedLabel  *adLabel;

@end
