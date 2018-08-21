//
//  TTVFeedListVideoItem.m
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import "TTVFeedListVideoItem.h"
#import "TTVFeedListVideoTopContainerView.h"
#import "TTVFeedListVideoBottomContainerView.h"
#import "TTVMacros.h"
#import "TTVFeedListVideoBottomContainerView.h"
#import "TTVAdActionButtonCreation.h"
#import "TTVFeedItem+Extension.h"
#import <KVOController/KVOController.h>

#import "NewsDetailConstant.h"
#import "ArticleDetailHeader.h"
#import "TTVCellPlayMovie.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedCellAction.h"
#import "TTVCellCommodityCenter.h"
#import "TTVPlayVideo.h"
#import "TTVDetailFollowRecommendView.h"
#import "UIView+CustomTimingFunction.h"
#import "TTVFeedUserOpViewSyncMessage.h"
#import "TTMessageCenter.h"
#import "TTVFeedListViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

extern BOOL ttvs_isVideoFeedshowDirectShare(void);

@implementation TTVFeedListVideoItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    CGFloat height = [super cellHeightWithWidth:width] + (self.showRelatedRecommendView ? self.recommendViewHeight : 0) + [TTVFeedListVideoTopContainerView obtainHeightForFeed:self cellWidth:ttv_feedContainerWidth(width)];
    return height;
}

@end

@interface TTVFeedListVideoCell ()
@property (nonatomic ,strong)TTVCellCommodityCenter *commodityCenter;
@property (nonatomic, strong) TTVDetailFollowRecommendView *recommendView;  //相关推荐
@end

@implementation TTVFeedListVideoCell

- (void)dealloc
{
    [self.item.KVOController unobserveAll];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.commodityCenter = [[TTVCellCommodityCenter alloc] init];
        _topContainerView = [[TTVFeedListVideoTopContainerView alloc] initWithFrame:CGRectZero];
        self.topMovieContainerView = _topContainerView.imageContainerView;
        @weakify(self);
        _topContainerView.imageContainerView.ttv_shareButtonOnMovieFinishViewDidPressBlock = ^{
            @strongify(self);
            [self.bottomContainerView shareActionClicked];
        };
        _topContainerView.imageContainerView.ttv_DirectShareOnMovieFinishViewDidPressBlock = ^(NSString *activityType) {
            @strongify(self);
            [self.bottomContainerView directShareOnmovieFinishViewWithActivityType:activityType];
        };
        _topContainerView.imageContainerView.ttv_DirectShareOnMovieViewDidPressBlock = ^(NSString *activityType) {
            @strongify(self);
            [self.bottomContainerView directShareOnMovieViewWithActivityType:activityType];
        };
        
        _topContainerView.imageContainerView.ttv_moreButtonOnMovieTopViewDidPressBlock = ^{
            @strongify(self);
            [self.bottomContainerView moreActionOnMovieTopViewClicked];
        };
        
        _topContainerView.imageContainerView.ttv_shareButtonOnMovieTopViewDidPressBlock = ^{
            @strongify(self);
            [self.bottomContainerView shareActionOnMovieTopViewClicked];
        };
        
        _topContainerView.imageContainerView.ttv_movieViewWillMoveToSuperViewBlock = ^(UIView *newView, BOOL animated) {
            @strongify(self);
            [self hiddenBottomAvatarViewIfNeed:newView animated:animated];
        };
        
        _topContainerView.imageContainerView.ttv_commodityViewClosedBlock = ^{
            @strongify(self);
            [self showBottomAvatarViewIfNeed];
        };
        
        _topContainerView.imageContainerView.ttv_commodityViewShowedBlock = ^{
            @strongify(self);
            [self hiddenBottomAvatarViewIfNeed];
        };
        _topContainerView.imageContainerView.ttv_playVideoBlock = ^{
            @strongify(self);
            [self.bottomContainerView openShareView];
        };
        _topContainerView.imageContainerView.ttv_videoPlayFinishedBlock = ^{
            @strongify(self);
            [self.bottomContainerView videoBottomContainerViewSetIsShowShareView];
        };
        _topContainerView.imageContainerView.ttv_videoReplayActionBlock = ^{
            @strongify(self);
            [self.bottomContainerView openShareView];
        };
        
        
        [self.containerView addSubview:_topContainerView];
        
        _bottomContainerView = [[TTVFeedListVideoBottomContainerView alloc] initWithFrame:CGRectZero];
        [_bottomContainerView.commentButton addTarget:self action:@selector(didClickButtonInsideCell:)];
        _bottomContainerView.moreActionType = ^(NSString *type) {
            @strongify(self);
            [self.commodityCenter moreActionTypeClick:type];
        };
        
        _bottomContainerView.recommendViewShowActionType = ^(BOOL clickArrow) {
            @strongify(self);
            self.recommendView.actionType = clickArrow ? @"click_show" : @"show";
        };
        [self.containerView addSubview:_bottomContainerView];
        _commodityCenter.bottomContainerView = self.bottomContainerView;
        _commodityCenter.topContainerView = self.topContainerView;
        
        if (!_recommendView){
            _recommendView = [[TTVDetailFollowRecommendView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.width, 0)];
            _recommendView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _recommendView.position = @"video_list";
            _recommendView.ifNeedToSendShowAction = NO;
            @weakify(self);
            _recommendView.recordContentOffsetblc = ^(CGPoint offset) {
                @strongify(self);
                CGFloat originX = offset.x;
                CGFloat maxOffsetX = self.recommendView.collectionView.contentSize.width - self.containerView.width;
                offset.x = MIN(originX, maxOffsetX);
                if (offset.x < 0){
                    offset.x = 0;
                }
                self.item.recommednViewContentOffset = offset;
                
            };
        }

    }
    return self;
}

- (void)updateRecommendView{
    if (self.item.recommendArray > 0){
        [self.recommendView.collectionView configUserModels:self.item.recommendArray];
        self.recommendView.top = self.bottomContainerView.bottom;
        self.recommendView.hidden = NO;
        self.recommendView.height = self.item.recommendViewHeight;
        CGPoint offset = self.item.recommednViewContentOffset;
        if (!CGPointEqualToPoint(offset, CGPointZero)) {
            self.recommendView.collectionView.contentOffset = self.item.recommednViewContentOffset;
        }
        [self.containerView insertSubview:self.recommendView belowSubview:self.topContainerView];
        if (!self.item.showRelatedRecommendView){
            self.recommendView.height = 0;
        }
    }
}

- (void)layoutRecommendViewWithclickArrow: (BOOL )clickArrow
{
//    if (!self.item.recommendArray){
//        return;
//    }
//    self.recommendView.hidden = NO;
//    if (!clickArrow && !self.item.showRelatedRecommendView){
//        self.item.recommendArray = nil;
//    }
    if (self.item.showRelatedRecommendView){
        self.recommendView.height = 0;
    }else{
        self.recommendView.height = self.item.recommendViewHeight;
        SAFECALL_MESSAGE(TTVFeedUserOpViewSyncMessage, @selector(ttv_message_feedListItemExpendOrCollapseRecommendView:isExpend:), ttv_message_feedListItemExpendOrCollapseRecommendView:self.item isExpend:NO);
    }

    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.25f];
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.39 :0.575 :0.565 :1]];
    [self.tableView beginUpdates];
    [UIView animateWithDuration:0.25f customTimingFunction:CustomTimingFunctionSineOut animation:^{
        if (self.item.showRelatedRecommendView){
            self.recommendView.height = self.item.recommendViewHeight;
        }else{
            self.recommendView.height = 0;
        }
    } completion:^(BOOL finished) {
        self.recommendView.isSpread = self.item.showRelatedRecommendView;
        [self.recommendView logRecommendViewAction];
        if (self.recommendView.isSpread) {
            [self.recommendView.collectionView willDisplay];
        }else{
            [self.recommendView.collectionView didEndDisplaying];
        }
    }];
    [self.tableView endUpdates];
    SAFECALL_MESSAGE(TTVFeedUserOpViewSyncMessage, @selector(ttv_message_feedListItemExpendOrCollapseRecommendView:isExpend:), ttv_message_feedListItemExpendOrCollapseRecommendView:self.item isExpend:YES);
    [CATransaction commit];
    [UIView commitAnimations];
    
}

- (NSString *)userId
{
    NSString *userId = [NSString stringWithFormat:@"%lld", self.item.originData.videoUserInfo.userId];
    return userId;
}

- (void)setItem:(TTVFeedListVideoItem *)item
{
    super.item = item;
    @weakify(self);
    [[[RACObserve(self.item, showRelatedRecommendView) skip:1] takeUntil:self.rac_prepareForReuseSignal]
      subscribeNext:^(id  _Nullable x) {
          @strongify(self);
         [self updateRecommendView];
         [self layoutRecommendViewWithclickArrow:NO];
    }];
    {
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_recommend" forKey:@"follow_type"];
        [rtFollowDict setValue:[self userId] forKey:@"profile_user_id"];
        TTVFeedListVideoItem *itemA = (TTVFeedListVideoItem *)self.item;
        [rtFollowDict setValue:itemA.categoryId forKey:@"category_name"];
        [rtFollowDict setValue:@"list_follow_card_related" forKey:@"source"];
        [rtFollowDict setValue:@(TTFollowNewSourceVideoListRecommend) forKey:@"server_source"];
        [rtFollowDict setValue:@"click_category" forKey:@"enter_from"];
        [rtFollowDict setValue:self.item.originData.logPb forKey:@"log_pb"];
        self.recommendView.rtFollowExtraDict = [rtFollowDict copy];
        self.recommendView.userID = [self userId];

    }
    self.topContainerView.cellEntity = item;
    self.bottomContainerView.cellEntity = item;
    item.moreButton = _bottomContainerView.moreButton;
    if (item.recommendArray){
        [self updateRecommendView];
        if (item.showRelatedRecommendView){
            if (!self.recommendView.actionType){
                self.recommendView.actionType = @"show";
            }
            self.recommendView.isSpread = self.item.showRelatedRecommendView;
        }
    }else{
        self.recommendView.hidden = YES;
        self.recommendView.height = 0;
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    TTVFeedListVideoItem *item = (TTVFeedListVideoItem *)self.item;
    
    self.topContainerView.top = 0;
    self.topContainerView.width = self.containerView.width;
    
    self.topContainerView.height = [item cellHeightWithWidth:self.containerView.width] - adBottomContainerViewHeight();
    if (item.cellSeparatorStyle == TTVFeedListCellSeparatorStyleHas) {
        self.topContainerView.height = [item cellHeightWithWidth:self.containerView.width] - adBottomContainerViewHeight() - self.separatorLineView.height - self.bottomPaddingView.height;
    }

    if (item.showRelatedRecommendView && self.recommendView.height > 0){
        self.topContainerView.height -= self.item.recommendViewHeight;
    }

    self.bottomContainerView.top = self.topContainerView.bottom;
    self.bottomContainerView.width = self.containerView.width;
    self.bottomContainerView.height = adBottomContainerViewHeight();
    
    self.separatorLineView.top = self.bottomContainerView.bottom;
    self.bottomPaddingView.top = self.separatorLineView.bottom;
    if (item.originData.videoUserInfo.follow) {
        if (item.recommendArray){
            self.recommendView.top = self.bottomContainerView.bottom;
            self.recommendView.width = self.containerView.width;
        }else{
            if (self.recommendView.layer.animationKeys.count < 1){
                self.recommendView.hidden = YES;
                self.recommendView.height = 0;
            }
        }
        
    }
    [super layoutSubviews];
}

- (void)cell_attachMovieView:(id)movieView {
    [super cell_attachMovieView:movieView];
    
    [self.bottomContainerView openShareView];
}

#pragma mark - Actions

- (void)didClickButtonInsideCell:(id)sender {
    if (sender == self.bottomContainerView.commentButton) {
        [self clickComment];
    }
}

- (void)clickComment
{
    TTVFeedListVideoItem *itemA = (TTVFeedListVideoItem *)self.item;
    TTVVideoArticle *article = itemA.originData.videoCell.article;
    NSString * screenName = [NSString stringWithFormat:@"channel_%@", itemA.categoryId];

    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:10];
    [extra setValue:itemA.categoryId forKey:@"category_name"];
    if ([itemA.categoryId isEqualToString:kTTMainCategoryID]) {
        [extra setValue:@"click_headline" forKey:@"enter_from"];
    }else{
        [extra setValue:@"click_category" forKey:@"enter_from"];
    }
    [extra setValue:[@(article.groupId) stringValue] forKey:@"group_id"];
    [extra setValue:@(article.itemId) forKey:@"item_id"];
    [extra setValue:@(article.aggrType) forKey:@"aggr_type"];
    [extra setValue:itemA.originData.logPbDic forKey:@"log_pb"];
    [TTTrackerWrapper eventV3:@"list_comment" params:extra];

    TTVFeedCellSelectContext *context = [[TTVFeedCellSelectContext alloc] init];
    context.screenName = screenName;
    context.refer = itemA.refer;
    context.clickComment = YES;
    context.categoryId = itemA.categoryId;
    context.feedListViewController = (TTVFeedListViewController *)[self findFirstViewControllerOfClass:[TTVFeedListViewController class]];
    [itemA.cellAction didSelectItem:itemA context:context];
}

- (void)willDisplayWithContext:(TTVFeedCellWillDisplayContext *)context
{
    if (self.item.showRelatedRecommendView) {
        [self.recommendView.collectionView willDisplay];
    }
}

- (void)endDisplayWithContext:(TTVFeedCellEndDisplayContext *)context
{
    [super endDisplayWithContext:context];
    
    [self.topContainerView.imageContainerView.playMovie didEndDisplaying];
    
    if (self.item.showRelatedRecommendView) {
        [self.recommendView.collectionView didEndDisplaying];
    }

}

- (void)hiddenBottomAvatarViewIfNeed:(UIView *)supView animated:(BOOL)animated {
    if(ttvs_isVideoFeedCellHeightAjust() > 1){
        if (!supView) {                    //removeFromSuperView
            if ([ self.topContainerView.imageContainerView.playMovie currentMovieView].superview == self.topContainerView.imageContainerView.logo) {
                if (!self.bottomContainerView.isShowShareView) {                 //外露分享渠道时,不显示头像
                    self.bottomContainerView.avatarView.hidden = NO;             //从self.logo remove，所以显示
                }
            }else{
                self.bottomContainerView.avatarView.hidden = YES;                //不是从self.logo remove ，则隐藏
            }
        }else {                            //willMoveToSuperView
            if (supView != self.topContainerView.imageContainerView.logo || !animated) {      //如果superview不是self.logo 则直接隐藏。
                self.bottomContainerView.avatarView.hidden = YES;
            }else{                                                               //superview是self.logo ,则动画隐藏
                [UIView animateWithDuration:.15
                                 animations:^{
                                     self.bottomContainerView.avatarView.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     if ([ self.topContainerView.imageContainerView.playMovie currentMovieView].superview == self.topContainerView.imageContainerView.logo) {
                                         self.bottomContainerView.avatarView.hidden = YES;
                                     }
                                     self.bottomContainerView.avatarView.alpha = 1;
                                 }];
            }
        }
    }
}

- (void)hiddenBottomAvatarViewIfNeed{
    if (ttvs_isVideoFeedCellHeightAjust() > 1){
        [UIView animateWithDuration:.15
                         animations:^{
                            self.bottomContainerView.avatarView.alpha = 0;
                       } completion:^(BOOL finished) {
                            self.bottomContainerView.avatarView.hidden = YES;
                            self.bottomContainerView.avatarView.alpha = 1;
                     }];
    }
}

- (void)showBottomAvatarViewIfNeed{
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        if ([ self.topContainerView.imageContainerView.playMovie currentMovieView].superview != self.topContainerView.imageContainerView.logo) {
            self.bottomContainerView.avatarView.hidden = NO;
        }
    }
}

@end
