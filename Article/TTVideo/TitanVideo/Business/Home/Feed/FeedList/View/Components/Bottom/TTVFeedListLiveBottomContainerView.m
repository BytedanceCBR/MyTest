//
//  TTVFeedListLiveBottomContainerView.m
//  Article
//
//  Created by pei yun on 2017/4/20.
//
//

#import "TTVFeedListLiveBottomContainerView.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTVFeedItem+Extension.h"
#import "TTVerifyIconHelper.h"
#import "TTIconLabel+VerifyIcon.h"

#define kLeftPadding        15
#define kRightPadding       15
#define kTopPadding         12
#define kGapAvatarView      8
extern CGFloat adBottomContainerViewHeight(void);

@implementation TTVFeedListLiveBottomContainerView

- (void)setCellEntity:(TTVFeedListItem *)cellEntity
{
    super.cellEntity = cellEntity;
    
    [self configureUI];
}

- (void)configureUI
{
    NSString *avatarUrl = nil;
    NSString *sourceText = nil;
    NSString *commentText = nil;
    NSString *liveCountText = nil;
    TTVUserInfo *userInfo = self.cellEntity.originData.videoUserInfo;
    TTVVideoArticle *article = self.cellEntity.article;
    
    avatarUrl = userInfo.avatarURL;
    sourceText = article.source;
    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userInfo.verifiedContent]) {
        [self.avatarLabel addIconWithVerifyInfo:userInfo.verifiedContent];
    }
    
    int64_t count = article.videoDetailInfo.videoWatchCount;
    liveCountText = [NSString stringWithFormat:@"累计%@人观看",[TTBusinessManager formatPlayCount:count]];
    int64_t cmtCnt = article.commentCount;
    commentText = cmtCnt > 0 ? [TTBusinessManager formatCommentCount:cmtCnt] : NSLocalizedString(@"评论", nil);
    
    [self updateAvatarViewWithUrl:avatarUrl sourceText:sourceText];
    [self updateAvatarLabelWithText:sourceText];
    [self updateLiveCountLabelWithText:liveCountText];
    
    [self themeChanged:nil];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarLabel.hidden = NO;
    self.liveCountLabel.hidden = NO;
    self.typeLabel.hidden = YES;
    
    CGFloat rightMargin = [TTDeviceHelper isPadDevice] ? self.width * 0.25 : 16;
    rightMargin = ceil(rightMargin);
    
    //更多按钮
    [self.moreButton updateFrames];
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.moreButton.top = 6.f;
    }else{
        self.moreButton.centerY = self.height / 2;
    }
    self.moreButton.right = [TTDeviceHelper isPadDevice] ? (self.width - 3) : (self.width - rightMargin + [self.moreButton contentEdgeInset].right);
    
    //直播在线人数
    _liveCountLabel.height = [self.class avatarHeight];
    _liveCountLabel.centerY = self.moreButton.centerY;
    _liveCountLabel.right = self.moreButton.left - rightMargin + [self.moreButton contentEdgeInset].left;
    
    //头像
    CGFloat left = kLeftPadding;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.avatarView.frame = CGRectMake(left, 8 - [self.class avatarHeight], [self.class avatarHeight], [self.class avatarHeight]);
        self.avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];
        self.avatarView.borderWidth = [self.class avatarViewBorderWidth];
    }else{
        self.avatarView.frame = CGRectMake(left, (self.height - [self.class avatarHeight]) / 2, [self.class avatarHeight], [self.class avatarHeight]);
        self.avatarView.borderWidth = 0.f;
        left += (!self.avatarView.hidden? [self.class avatarHeight] + kGapAvatarView : 0);
    }
    
    //名称
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.avatarLabel.frame = CGRectMake(left, 9, self.avatarLabel.width, 28.f);
    }else{
        self.avatarLabel.left = left;
        self.avatarLabel.height = [TTDeviceUIUtils tt_newPadding:32.0];
        self.avatarLabel.centerY = self.moreButton.centerY;
    }
    
    CGFloat avatarLabelWidth = _liveCountLabel.left - self.avatarLabel.left - 20;
    avatarLabelWidth = avatarLabelWidth < self.avatarLabel.width ? avatarLabelWidth : self.avatarLabel.width;
    self.avatarLabel.width = avatarLabelWidth;
    
    //控制头像以及名称透明度按钮
    self.avatarViewButton.frame = self.avatarView.frame;
    CGFloat labelButtonHeight = adBottomContainerViewHeight();
    if (ttvs_isVideoFeedCellHeightAjust() > 2) {
        labelButtonHeight += 4; //52+4
    }
    self.avatarLabelButton.frame = CGRectMake(self.avatarView.left, 0, self.avatarLabel.right - self.avatarView.left, labelButtonHeight);
}

/** 直播状态在线人数 */
- (SSThemedLabel *)liveCountLabel {
    if (!_liveCountLabel) {
        _liveCountLabel = [[SSThemedLabel alloc] init];
        _liveCountLabel.backgroundColor = [UIColor clearColor];
        _liveCountLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _liveCountLabel.textAlignment = NSTextAlignmentRight;
        _liveCountLabel.textColorThemeKey = kColorText3;
        _liveCountLabel.height = adBottomContainerViewHeight();
        [self addSubview:_liveCountLabel];
    }
    return _liveCountLabel;
}

- (void)updateLiveCountLabelWithText:(NSString *)liveCountText
{
    if (!isEmptyString(liveCountText)) {
        [self.liveCountLabel setText:liveCountText];
        [_liveCountLabel sizeToFit];
    }
}

@end
