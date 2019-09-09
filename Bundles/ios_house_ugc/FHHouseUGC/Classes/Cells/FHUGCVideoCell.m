//
//  FHUGCVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/5.
//

#import "FHUGCVideoCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "FHUGCCellOriginItemView.h"
#import "TTRoute.h"
#import <TTBusinessManager+StringUtils.h>
#import "FHUGCVideoView.h"
#import <TTVFeedPlayMovie.h>
#import <TTVCellPlayMovieProtocol.h>
#import <TTVPlayVideo.h>
#import <TTVCellPlayMovie.h>
#import <TTVFeedCellMoreActionManager.h>

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20

@interface FHUGCVideoCell ()<TTUGCAttributedLabelDelegate,TTVFeedPlayMovie>

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) CGFloat videoViewheight;
@property(nonatomic ,strong) FHUGCVideoView *videoView;
@property(nonatomic ,strong) TTVFeedCellMoreActionManager *moreActionMananger;

@end

@implementation FHUGCVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeRed3],
                                     NSFontAttributeName : [UIFont themeFontRegular:16]
                                     };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.videoViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0;
    self.videoView = [[FHUGCVideoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, self.videoViewheight)];
    [self.contentView addSubview:_videoView];

    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    
    __weak typeof(self) wself = self;
    self.videoView.ttv_shareButtonOnMovieFinishViewDidPressBlock = ^{
        [wself shareActionClicked];
    };
}

- (void)initConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.height.mas_equalTo(([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoView.mas_bottom).offset(10);
        make.height.mas_equalTo(49);
        make.left.right.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    self.cellModel = cellModel;
    //设置userInfo
    self.userInfoView.cellModel = cellModel;
    self.userInfoView.userName.text = cellModel.user.name;
    self.userInfoView.descLabel.attributedText = cellModel.desc;
    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    //设置底部
    self.bottomView.cellModel = cellModel;
    
    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
    self.bottomView.position.text = cellModel.community.name;
    [self.bottomView showPositionView:showCommunity];
    
    NSInteger commentCount = [cellModel.commentCount integerValue];
    if(commentCount == 0){
        [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        [self.bottomView.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
    }
    [self.bottomView updateLikeState:cellModel.diggCount userDigg:cellModel.userDigg];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
        [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
            make.height.mas_equalTo(self.videoViewheight);
        }];
    }else{
        self.contentLabel.hidden = NO;
        [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
            make.height.mas_equalTo(self.videoViewheight);
        }];
        [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel];
    }
    //处理视频
    self.videoItem = [FHUGCCellHelper configureVideoItem:cellModel];
    self.videoView.cellEntity = self.videoItem;
    
    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = cellModel.contentHeight + userInfoViewHeight + bottomViewHeight + topMargin + 30;
        
        if(isEmptyString(cellModel.content)){
            height -= 10;
        }
        
        CGFloat videoViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0;
        height += videoViewheight;
        
        if(cellModel.isInsertGuideCell){
            height += guideViewHeight;
        }
        
        return height;
    }
    return 44;
}

- (void)showGuideView {
    if(_cellModel.isInsertGuideCell){
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(66);
        }];
    }else{
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(49);
        }];
    }
}

- (void)closeGuideView {
    self.cellModel.isInsertGuideCell = NO;
    [self.cellModel.tableView beginUpdates];
    
    [self showGuideView];
    self.bottomView.cellModel = self.cellModel;
    
    [self setNeedsUpdateConstraints];
    
    [self.cellModel.tableView endUpdates];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeFeedGuide:)]){
        [self.delegate closeFeedGuide:self.cellModel];
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

// 评论点击
- (void)commentBtnClick {
    if(self.delegate && [self.delegate respondsToSelector:@selector(commentClicked:cell:)]){
        [self.delegate commentClicked:self.cellModel cell:self];
    }
}

//进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
        [self.delegate goToCommunityDetail:self.cellModel];
    }
}

- (void)willDisplay {

}

- (void)endDisplay {
    [[self playMovie] didEndDisplaying];
}

#pragma mark - TTUGCAttributedLabelDelegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if([url.absoluteString isEqualToString:defaultTruncationLinkURLString]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(lookAllLinkClicked:cell:)]){
            [self.delegate lookAllLinkClicked:self.cellModel cell:self];
        }
    } else {
        if (url) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(gotoLinkUrl:url:)]){
                [self.delegate gotoLinkUrl:self.cellModel url:url];
            }
        }
    }
}

#pragma mark - TTVFeedPlayMovie

- (UIView *)movie {
    if (self.videoView == nil) {
        return nil;
    }
    return [[self playMovie] currentMovieView];
}

- (NSObject<TTVCellPlayMovieProtocol> *)playMovie {
    if (self.videoView == nil) {
        return nil;
    }
    return self.videoView.playMovie;
}

- (UIView *)cell_movieView {
    if (self.videoView == nil) {
        return nil;
    }
    return [self movie];
}

- (BOOL)cell_hasMovieView {
    if (self.videoView == nil) {
        return NO;
    }
    return [self movie] != nil;
}

- (BOOL)cell_isPlayingMovie
{
    if (self.videoView == nil) {
        return NO;
    }
    if ([self movie] && [self playMovie]) {
        return YES;
    }
    return NO;
}

- (void)cell_attachMovieView:(UIView *)movieView {
    if (self.videoView == nil) {
        return;
    }
    if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
        UIView *logo = self.videoView.logo;
        movieView.frame = logo.bounds;
        [logo addSubview:movieView];
        if (self.videoView.playMovie == nil && [self.videoItem isKindOfClass:[TTVFeedListItem class]]) {
            [self.videoView playButtonClicked];
            FHFeedContentModel *model = (FHFeedContentModel *)self.videoItem.originData;
            [[self playMovie] setVideoTitle:model.title];
            [self playMovie].logo = logo;
        }
        [self.videoView.playMovie attachMovieView:(TTVPlayVideo *)movieView];
        // attatch的时候，禁用动画
        self.videoView.ttv_movieViewWillMoveToSuperViewBlock(movieView.superview, NO);
    }
}

- (id)cell_detachMovieView {
    if (self.videoView == nil) {
        return nil;
    }
    return [self.videoView.playMovie detachMovieView];
}

- (void)shareActionClicked {
    [self _shareAction];
}

- (void)_shareAction {
    self.moreActionMananger = [[TTVFeedCellMoreActionManager alloc] init];
    self.moreActionMananger.categoryId = self.videoItem.categoryId;
    self.moreActionMananger.responder = self;
    self.moreActionMananger.cellEntity = self.videoItem.originData;
    self.moreActionMananger.playVideo = self.videoItem.playVideo;
    __weak typeof(self) wself = self;
    self.moreActionMananger.didClickActivityItemAndQueryProcess = ^BOOL(NSString *type) {
        return NO;
    };
    self.moreActionMananger.shareToRepostBlock = ^(TTActivityType type) {

    };
    [self.moreActionMananger shareButtonClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.videoItem.originData] activityAction:^(NSString *type) {
        
    }];

}

@end
