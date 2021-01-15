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
#import "TTAsyncCornerImageView.h"
#import "FHUGCCommonAvatar.h"
#import "FHEnvContext.h"
#import "FHAnswerLayout.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 30
#define bottomViewHeight 45
#define topMargin 20

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
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    [self.contentView addSubview:_userInfoView];
    
    
    self.userIma = [[FHUGCCommonAvatar alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [_userIma setPlaceholderImage:@"fh_mine_avatar"];
    _userIma.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.userIma];
    
    self.username = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    self.username.textAlignment = NSTextAlignmentLeft;
    self.username.userInteractionEnabled = YES;
    [self.contentView addSubview:_username];
    
    self.useride = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    self.useride.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_useride];
    
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
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
}

- (void)updateConstraints:(FHBaseLayout *)layout {
    if (![layout isKindOfClass:[FHAnswerLayout class]]) {
        return;
    }
    
    FHAnswerLayout *cellLayout = (FHAnswerLayout *)layout;
    
    [FHLayoutItem updateView:self.userInfoView withLayout:cellLayout.userInfoViewLayout];
    [FHLayoutItem updateView:self.userIma withLayout:cellLayout.userImaLayout];
    [FHLayoutItem updateView:self.username withLayout:cellLayout.usernameLayout];
    [FHLayoutItem updateView:self.useride withLayout:cellLayout.userideLayout];
    [FHLayoutItem updateView:self.contentLabel withLayout:cellLayout.contentLabelLayout];
    [FHLayoutItem updateView:self.multiImageView withLayout:cellLayout.multiImageViewLayout];
    [FHLayoutItem updateView:self.singleImageView withLayout:cellLayout.singleImageViewLayout];
    [FHLayoutItem updateView:self.bottomView withLayout:cellLayout.bottomViewLayout];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.backgroundColor = [UIColor whiteColor];
    label.layer.masksToBounds = YES;
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
    [self updateConstraints:cellModel.layout];
    //设置userInfo
    [self updateUserInfoView:cellModel];
    //设置底部
    [self.bottomView refreshWithData:cellModel];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
    }else{
        self.contentLabel.hidden = NO;
        NSAttributedString *more =   [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:14]
                   contentColor:[UIColor themeGray1]
                          color:[UIColor themeRed3]];
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel truncatedToken:more];
    }
    //图片
    if(cellModel.imageList.count > 1){
        self.multiImageView.hidden = NO;
        self.singleImageView.hidden = YES;
        [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    }else if(cellModel.imageList.count == 1){
        self.multiImageView.hidden = YES;
        self.singleImageView.hidden = NO;
        [self.singleImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    }else{
        self.multiImageView.hidden = YES;
        self.singleImageView.hidden = YES;
    }
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
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        return cellModel.layout.height;
    }
    return 44;
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
