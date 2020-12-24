//
//  FHUGCAnswerCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/7/29.
//

#import "FHUGCAnswerCell.h"

#import "UIImageView+BDWebImage.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "FHUGCCellOriginItemView.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIViewAdditions.h"
#import "FHUGCCellAttachCardView.h"
#import "TTAsyncCornerImageView.h"
#import "FHUGCCommonAvatar.h"
#import "FHEnvContext.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 30
#define bottomViewHeight 46
#define guideViewHeight 17
#define topMargin 20
#define originViewHeight 80
#define attachCardViewHeight 57

@interface FHUGCAnswerCell ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic, strong) FHUGCCommonAvatar *userIma;
@property(nonatomic, strong) UILabel *username;
@property(nonatomic, strong) UILabel *useride;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellMultiImageView *singleImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,strong) FHUGCCellAttachCardView *attachCardView;
@property(nonatomic, strong) TTAsyncCornerImageView *contentImage;
//@property(nonatomic ,assign) CGFloat imageViewheight;

@end

@implementation FHUGCAnswerCell

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
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    [self.contentView addSubview:_userInfoView];
    
    
    self.userIma = [[FHUGCCommonAvatar alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_userIma setPlaceholderImage:@"fh_mine_avatar"];
    _userIma.contentMode = UIViewContentModeScaleAspectFill;
//    _userIma.borderWidth = 1;
//    _userIma.borderColor = [UIColor themeGray6];
    [self addSubview:self.userIma];
    
    self.username = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    self.username.textAlignment = NSTextAlignmentLeft;
    self.username.userInteractionEnabled = YES;
    [self addSubview:_username];
    
    self.useride = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    self.useride.textAlignment = NSTextAlignmentLeft;
    self.useride.userInteractionEnabled = YES;
    [self addSubview:_useride];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0)];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.delegate = self;
    _contentLabel.font = [UIFont themeFontRegular:14];
    [self.contentView addSubview:_contentLabel];
    
    
    self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:3];
    _multiImageView.hidden = YES;
    [self.contentView addSubview:_multiImageView];
    
    self.singleImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:1];
    _singleImageView.hidden = YES;
    _singleImageView.fixedSingleImage = YES;
    [self.contentView addSubview:_singleImageView];
    
    
    self.attachCardView = [[FHUGCCellAttachCardView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, attachCardViewHeight)];
    _attachCardView.hidden = YES;
    [self.contentView addSubview:_attachCardView];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)initConstraints {
    self.userInfoView.top = topMargin;
    self.userInfoView.left = 0;
    self.userInfoView.width = [UIScreen mainScreen].bounds.size.width;
    self.userInfoView.height = userInfoViewHeight;
    
    self.userIma.top =  self.userInfoView.bottom + 5;
    self.userIma.left = leftMargin;
    self.userIma.width = 20;
    self.userIma.height = 20;
    
    self.username.centerY =  self.userIma.centerY;
    self.username.left = self.userIma.right + 4;
    self.username.height = 18;
    
    self.useride.centerY =  self.username.centerY;
    self.useride.left = self.username.right + 4;
    self.useride.height = 18;
    
    
    self.contentLabel.top = self.userIma.bottom + 5;
    self.contentLabel.left = leftMargin;
    self.contentLabel.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.contentLabel.height = 0;
    
    self.contentImage.top = 0;
    self.contentImage.left = 0;
    self.contentImage.width = 20;
    self.contentImage.height = 20;
    
    self.multiImageView.top = self.contentLabel.bottom + 10;
    self.multiImageView.left = leftMargin;
    self.multiImageView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.multiImageView.height = [FHUGCCellMultiImageView viewHeightForCount:3 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
    
    self.singleImageView.top = self.contentLabel.bottom + 10;
    self.singleImageView.left = leftMargin;
    self.singleImageView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.singleImageView.height = [FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];

    self.bottomView.top = self.multiImageView.bottom + 10;
    self.bottomView.left = 0;
    self.bottomView.width = [UIScreen mainScreen].bounds.size.width;
    self.bottomView.height = bottomViewHeight;
    
    
    self.attachCardView.top = self.multiImageView.bottom + 10;
    self.attachCardView.left = leftMargin;
    self.attachCardView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.attachCardView.height = attachCardViewHeight;
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
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    if(self.currentData == data && !cellModel.ischanged){
        return;
    }
    
    self.currentData = data;
    self.cellModel = cellModel;
    //设置userInfo
    [self updateUserInfoView:cellModel];
    
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
        self.contentLabel.height = 0;
        self.multiImageView.top = self.userIma.bottom + 10;
        self.singleImageView.top = self.userIma.bottom + 10;
    }else{
        self.contentLabel.hidden = NO;
        self.contentLabel.height = cellModel.contentHeight;
        NSAttributedString *more =   [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:14]
                   contentColor:[UIColor themeGray1]
                          color:[UIColor themeRed3]];
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel truncatedToken:more];
        self.multiImageView.top = self.userIma.bottom + 15 + cellModel.contentHeight;
        self.singleImageView.top = self.userIma.bottom + 15 + cellModel.contentHeight;
    }

    UIView *lastView = self.contentLabel;
    CGFloat topOffset = 10;
    //图片
    if(cellModel.imageList.count > 1){
        lastView = self.multiImageView;
        self.multiImageView.hidden = NO;
        self.singleImageView.hidden = YES;
        [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    }else if(cellModel.imageList.count == 1){
        lastView = self.singleImageView;
        self.multiImageView.hidden = YES;
        self.singleImageView.hidden = NO;
        [self.singleImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    }else{
        lastView = self.contentLabel;
        self.multiImageView.hidden = YES;
        self.singleImageView.hidden = YES;
    }
//    [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    
    //attach card
    if(cellModel.attachCardInfo){
        self.attachCardView.hidden = NO;
        [self.attachCardView refreshWithdata:cellModel];
        self.attachCardView.top = lastView.bottom + topOffset;
        topOffset += attachCardViewHeight;
        topOffset += 10;
    }else{
        self.attachCardView.hidden = YES;
    }
    
    self.bottomView.top = lastView.bottom + topOffset;
    
    [self showGuideView];
}

- (void)updateUserInfoView:(FHFeedUGCCellModel *)cellModel {
    [self.userInfoView setTitleModel:cellModel];
    self.username.text = cellModel.user.name;
    NSArray *vwhiteList =  [FHEnvContext getUGCUserVWhiteList];
    if ([vwhiteList containsObject:cellModel.user.userId]) {
        self.useride.text = cellModel.user.verifiedContent;
    } else {
        self.useride.text = @"";
    }

    [self.userIma setAvatarUrl:cellModel.user.avatarUrl];
    self.userIma.userId = cellModel.user.userId;
    NSString *titleStr =  !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"    %@",cellModel.originItemModel.content] : @"";
    CGRect titleRect = [titleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontMedium:16]} context:nil];
//    CGSize size = [titleStr sizeWithFont:[UIFont themeFontMedium:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 30) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat maxTitleLabelSizeWidth = [UIScreen mainScreen].bounds.size.width - 10 - 50 -5;
    if(titleRect.size.width > maxTitleLabelSizeWidth){
        self.userInfoView.height = 50;
    }else {
         self.userInfoView.height = 30;
    }
    [self updateFarme];
}

- (void)updateFarme {
    self.userIma.top =  self.userInfoView.bottom + 5;
    CGRect titleRect = [self.username.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontMedium:16]} context:nil];
    self.username.width = titleRect.size.width;
    self.useride.width =  [UIScreen mainScreen].bounds.size.width-30 -40 -titleRect.size.width;
    self.username.centerY =  self.userIma.centerY;
    self.useride.centerY =  self.username.centerY;
    self.useride.left = self.username.right + 4;
    self.contentLabel.top = self.userIma.bottom + 5;
    self.multiImageView.top = self.contentLabel.bottom + 10;
    self.singleImageView.top = self.contentLabel.bottom + 10;
    self.bottomView.top = self.multiImageView.bottom + 10;
    self.attachCardView.top = self.multiImageView.bottom + 10;
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        NSString *titleStr =  !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"    %@",cellModel.originItemModel.content] : @"";
        CGRect titleRect = [titleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontMedium:16]} context:nil];
        CGFloat maxTitleLabelSizeWidth = [UIScreen mainScreen].bounds.size.width - 10 - 50 -5;
        CGFloat userInfoHeight = 0;
        if(titleRect.size.width > maxTitleLabelSizeWidth){
            userInfoHeight = 50;
        }else {
            userInfoHeight = 30;
        }
        CGFloat height = userInfoHeight +30+ bottomViewHeight + topMargin;
        
        if(!isEmptyString(cellModel.content)){
            height += (cellModel.contentHeight + 10);
        }
        
        if(cellModel.imageList.count > 1){
            CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:3 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
            height += (imageViewheight + 10);
        }else if(cellModel.imageList.count == 1){
            CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
            height += (imageViewheight + 10);
        }
        
        if(cellModel.attachCardInfo){
            height += (attachCardViewHeight + 10);
        }
        
        if(cellModel.isInsertGuideCell){
            height += guideViewHeight;
        }
        return height;
    }
    return 44;
}

- (void)showGuideView {
    if(_cellModel.isInsertGuideCell){
        self.bottomView.height = bottomViewHeight + guideViewHeight;
    }else{
        self.bottomView.height = bottomViewHeight;
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

#pragma mark - TTUGCAsyncLabelDelegate

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url {
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

@end
