//
//  FHUGCSmallVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/5.
//

#import "FHUGCSmallVideoCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "FHUGCCellOriginItemView.h"
#import "TTRoute.h"
#import <TTBusinessManager+StringUtils.h>
#import <UIView+XWAddForRoundedCorner.h>

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20
#define originViewHeight 80

@interface FHUGCSmallVideoCell ()<TTUGCAttributedLabelDelegate>

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,strong) FHUGCCellOriginItemView *originView;
@property(nonatomic ,assign) CGFloat imageViewheight;
@property(nonatomic ,assign) CGFloat imageViewWidth;
@property (nonatomic, strong)   UIImageView       *playIcon;
@property (nonatomic, strong)   UIView       *timeBgView;
@property (nonatomic, strong)   UILabel       *timeLabel;

@end

@implementation FHUGCSmallVideoCell

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
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeRed3],
                                     NSFontAttributeName : [UIFont themeFontRegular:16]
                                     };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.videoImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
    _videoImageView.backgroundColor = [UIColor themeGray7];
    _videoImageView.layer.masksToBounds = YES;
//    _videoImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
//    _videoImageView.layer.borderWidth = 0.5;
//    _videoImageView.layer.cornerRadius = 4;
    _videoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    _videoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_videoImageView xw_roundedCornerWithCornerRadii:CGSizeMake(4, 4) cornerColor:[UIColor whiteColor] corners:UIRectCornerAllCorners borderColor:[UIColor themeGray6] borderWidth:0.5];
    [self.contentView addSubview:_videoImageView];
    self.imageViewheight = 200;
    self.imageViewWidth = 150;
    
    self.playIcon = [[UIImageView alloc] init];
    self.playIcon.image = [UIImage imageNamed:@"fh_ugc_icon_videoplay"];
    [self.videoImageView addSubview:self.playIcon];
    
    self.timeBgView = [[UIView alloc] init];
    self.timeBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.timeBgView.layer.cornerRadius = 10.0;
    self.timeBgView.clipsToBounds = YES;
    [self.videoImageView addSubview:self.timeBgView];
    
    self.timeLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeWhite]];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.timeBgView addSubview:self.timeLabel];
    
    self.originView = [[FHUGCCellOriginItemView alloc] initWithFrame:CGRectZero];
    _originView.hidden = YES;
    [self.contentView addSubview:_originView];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
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
    
    [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.height.mas_equalTo(self.imageViewheight);
    }];
    
    [self.playIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.videoImageView);
        make.width.height.mas_equalTo(44);
    }];
    
    [self.timeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.videoImageView.mas_right).offset(-4);
        make.bottom.mas_equalTo(self.videoImageView.mas_bottom).offset(-4);
        make.height.mas_equalTo(20);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.timeBgView);
        make.height.mas_equalTo(14);
        make.left.mas_equalTo(6);
        make.right.mas_equalTo(-6);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(49);
        make.left.right.mas_equalTo(self.contentView);
    }];
    
    [self.originView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(originViewHeight);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
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
    //图片
    if (cellModel.imageList.count > 0) {
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        CGFloat wid = [imageModel.width floatValue];
        CGFloat hei = [imageModel.height floatValue];
        if (wid <= hei) {
            self.imageViewheight = 200;
            self.imageViewWidth = 150;
        } else {
            self.imageViewheight = 152;
            self.imageViewWidth = 270;
        }
        
        if (imageModel && imageModel.url.length > 0) {
            TTImageInfosModel *imageInfoModel = [FHUGCCellHelper convertTTImageInfosModel:imageModel];
            __weak typeof(self) wSelf = self;
            [self.videoImageView setImageWithModelInTrafficSaveMode:imageInfoModel placeholderImage:nil success:nil failure:^(NSError *error) {
                [wSelf.videoImageView setImage:nil];
            }];
        }
    }
    // 时间
    NSString *timeStr = @"00:00";
    if (cellModel.videoDuration > 0) {
        NSInteger minute = cellModel.videoDuration / 60;
        NSInteger second = cellModel.videoDuration % 60;
        NSString *mStr = @"00";
        if (minute < 10) {
            mStr = [NSString stringWithFormat:@"%02ld",minute];
        } else {
            mStr = [NSString stringWithFormat:@"%ld",minute];
        }
        NSString *sStr = @"00";
        if (second < 10) {
            sStr = [NSString stringWithFormat:@"%02ld",second];
        } else {
            sStr = [NSString stringWithFormat:@"%ld",second];
        }
        timeStr = [NSString stringWithFormat:@"%@:%@",mStr,sStr];
    }
    self.timeLabel.text = timeStr;
    // [self.timeLabel sizeToFit];
    [self.timeLabel layoutIfNeeded];
    
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
        [self.videoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.width.mas_equalTo(self.imageViewWidth);
            make.height.mas_equalTo(self.imageViewheight);
        }];
    }else{
        self.contentLabel.hidden = NO;
        [self.videoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.width.mas_equalTo(self.imageViewWidth);
            make.height.mas_equalTo(self.imageViewheight);
        }];
        [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel];
    }
    //origin
    if(cellModel.originItemModel){
        self.originView.hidden = NO;
        [self.originView refreshWithdata:cellModel];
        [self.originView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cellModel.originItemHeight);
        }];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.videoImageView.mas_bottom).offset(cellModel.originItemHeight + 20);
        }];
    }else{
        self.originView.hidden = YES;
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.videoImageView.mas_bottom).offset(10);
        }];
    }
    
    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = cellModel.contentHeight + userInfoViewHeight + bottomViewHeight + topMargin + 30;
        
        if(isEmptyString(cellModel.content)){
            height -= 10;
        }
        
        CGFloat imageViewheight = 200;
        if (cellModel.imageList.count > 0) {
            FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
            CGFloat wid = [imageModel.width floatValue];
            CGFloat hei = [imageModel.height floatValue];
            if (wid <= hei) {
                imageViewheight = 200;
            } else {
                imageViewheight = 152;
            }
        }
        
        height += imageViewheight;
        
        if(cellModel.originItemModel){
            height += (cellModel.originItemHeight + 10);
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

@end
