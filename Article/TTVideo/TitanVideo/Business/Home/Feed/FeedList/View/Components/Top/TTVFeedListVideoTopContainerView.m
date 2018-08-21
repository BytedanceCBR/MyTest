//
//  TTVFeedListVideoTopContainerView.m
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListVideoTopContainerView.h"
#import "TTVFeedListTopImageContainerView.h"

#import "ExploreArticleCellViewConsts.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTImageInfosModel.h"
#import "ExploreArticleVideoCellCommentView.h"
#import "TTMovieViewCacheManager.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTVideoEmbededAdButton.h"
#import "TTLabelTextHelper.h"
#import "TTImageView+TrafficSave.h"

@interface TTVFeedListVideoTopContainerView ()

@property (nonatomic, strong) TTVFeedListTopImageContainerView *imageContainerView;
@property (nonatomic, strong) TTAlphaThemedButton *playButton;

@end

@implementation TTVFeedListVideoTopContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageContainerView = [[TTVFeedListTopImageContainerView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageContainerView];
    }
    return self;
}

- (void)setCellEntity:(TTVFeedListItem *)cellEntity
{
    _cellEntity = cellEntity;
    _imageContainerView.cellEntity = cellEntity;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageContainerView.frame = self.bounds;
}

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width
{
    return [TTVFeedListTopImageContainerView obtainHeightForFeed:cellEntity cellWidth:width];
}

@end
