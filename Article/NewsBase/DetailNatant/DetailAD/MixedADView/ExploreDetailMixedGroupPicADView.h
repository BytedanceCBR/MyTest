//
//  ExploreDetailMixedGroupPicADView.h
//  Article
//
//  Created by 冯靖君 on 16/7/11.
//
//

#import "ExploreDetailBaseADView.h"

#define kGroupPicViewImagesCount    3
#define kTopMargin      9.f
#define kBottomMargin   7.f
#define kActionBottomMargin 14.f    //创意通投bottomMargin
#define kHoriMargin     12.f
#define kPicSpace       2.f
#define kPicTopSpace    6.f
#define kPicAspect      0.653
#define kADLabelMargin  6.f

#define kDislikeImageWidth 20

#define kMixDislikeImageWidth 10
#define kMixDislikeImageTopPadding 14
#define kMixDislikeImageRightPadding 12
#define kMixDislikeImageLeftPadding 15

@interface ExploreDetailADGroupPicView : SSThemedView
@property(nonatomic, assign) CGSize picSize;

- (instancetype)initWithWidth:(CGFloat)width;
- (void)refreshWithImageList:(NSArray<NSDictionary *> *)urlList;
+ (CGFloat)heightForWidth:(CGFloat)width;

@end


@interface ExploreDetailMixedGroupPicADView : ExploreDetailBaseADView

@property(nonatomic, strong) SSThemedLabel *titleLabel;
@property(nonatomic, strong) ExploreDetailADGroupPicView *groupPicView;
@property(nonatomic, strong) SSThemedLabel *adLabel;
@property(nonatomic, strong) SSThemedLabel *sourceLabel;

- (void)layout;

@end
