//
//  TTVFeedListPicAdCell.m
//  Article
//
//  Created by panxiang on 2017/3/2.
//
//

#import "TTVFeedListPicAdItem.h"
#import "TTVMacros.h"
#import "TTVAdActionButtonCreation.h"
#import "TTVFeedItem+Extension.h"
#import "ExploreActionButton.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTADEventTrackerEntity.h"
#import "TTVADEventTracker.h"

 /// 新增了文章类型的广告，实际是文章，但是 广告的属性都包含在 ad_data里面，为了避免新建很多字段进行存储，就直接dump成string存储 article的adPromoter字段 对应服务端ad_data. 对应 ExploreOrderedADModel
//1.ad_data 创意广告,  ad_button 视频内嵌广告 .
// embededAdInfo 对应 ad_button 对应 ExploreOrderedADModel
// 2. raw_ad_data 统一 ad_data ad_button
//videoEmbededAdInfo 对应ad_video_info TTDetailNatantVideoAdModel

extern UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void);
extern UIColor *tt_ttuisettingHelper_cellViewHighlightedBackgroundColor(void);

@implementation TTVFeedListPicAdItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return [super cellHeightWithWidth:width] + [TTVFeedListAdPicTopContainerView obtainHeightForFeed:self cellWidth:ttv_feedContainerWidth(width)];
}
@end

@interface TTVFeedListPicAdCell ()

@end

@implementation TTVFeedListPicAdCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _topContainerView = [[TTVFeedListAdPicTopContainerView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_topContainerView];
        
        _bottomContainerView = [[TTVFeedListAdBottomContainerView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_bottomContainerView];
    }
    return self;
}

- (void)setItem:(TTVFeedListPicAdItem *)item
{
    super.item = item;
    
    TTVFeedItem *feed = item.originData;
    TTVAdActionButton *adActionButton = getAdActionButtonInstance(feed.videoBusinessType);
    adActionButton.ttv_command.feedItem = item.originData;
    item.ttv_command = adActionButton.ttv_command;
    self.bottomContainerView.adActionButton = adActionButton;
    self.topContainerView.cellEntity = item;
    self.bottomContainerView.cellEntity = item;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    TTVFeedListPicAdItem *item = (TTVFeedListPicAdItem *)self.item;
    
    self.topContainerView.width = self.containerView.width;
    
    self.topContainerView.height = self.containerView.height - adBottomContainerViewHeight();
    if (item.cellSeparatorStyle == TTVFeedListCellSeparatorStyleHas) {
        self.topContainerView.height = self.containerView.height - adBottomContainerViewHeight() - self.separatorLineView.height - self.bottomPaddingView.height;
    }
    self.bottomContainerView.top = self.topContainerView.bottom;
    self.bottomContainerView.width = self.containerView.width;
    self.bottomContainerView.height = adBottomContainerViewHeight();
    
    self.separatorLineView.top = self.bottomContainerView.bottom;
    self.bottomPaddingView.top = self.separatorLineView.bottom;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = tt_ttuisettingHelper_cellViewHighlightedBackgroundColor();
    } else {
        self.backgroundColor = tt_ttuisettingHelper_cellViewBackgroundColor();
    }
    self.bottomContainerView.backgroundColor = self.backgroundColor;
    self.contentView.backgroundColor = self.backgroundColor;
}

// 首页列表cell点击处理
- (void)didSelectWithContext:(TTVFeedCellSelectContext *)context
{
    [super didSelectWithContext:context];
}

- (void)endDisplayWithContext:(TTVFeedCellEndDisplayContext *)context
{
    [super endDisplayWithContext:context];
}

- (void)cellForRowContext:(TTVFeedCellForRowContext *)context
{
    [super cellForRowContext:context];
}

- (void)willDisplayWithContext:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayWithContext:context];    
}

@end
