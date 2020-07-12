//
//  FHHouseDeatilRGCVideoCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/17.
//

#import "FHHouseDeatilRGCVideoCell.h"
#import "FHHouseDeatilRGCCellHeader.h"
#import "FHUGCCellBottomView.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHelper.h"
#import "FHUGCCellUserInfoView.h"
#import "UIViewAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#define leftMargin 20
#define rightMargin 20
#define topMargin 5
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 70
@interface FHHouseDeatilRGCVideoCell()<TTUGCAsyncLabelDelegate>
@property(nonatomic ,strong) UIView *contentContainer;
@property (strong, nonatomic) TTUGCAsyncLabel *contentLabel;
@property (strong, nonatomic) FHUGCCellBottomView *bottomView;
@property (strong, nonatomic) FHHouseDeatilRGCCellHeader *headerView;
@property (strong ,nonatomic) FHUGCCellUserInfoView *userInfoView;
@property (strong ,nonatomic) FHUGCCellUserInfoView *lineView;
@property (nonatomic ,assign) CGFloat imageViewheight;
@property (nonatomic  ,assign) CGFloat imageViewWidth;
@property (nonatomic ,strong) UIImageView *playIcon;
@property (nonatomic ,strong) UIView       *timeBgView;
@property (nonatomic ,strong) UILabel       *timeLabel;
@property (nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@end
@implementation FHHouseDeatilRGCVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {

      self.contentView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor clearColor];
      // 背景容器
      self.contentContainer = [UIView new];
      self.contentContainer.backgroundColor = [UIColor themeWhite];
      [self.contentView addSubview:self.contentContainer];
    
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, userInfoViewHeight)];
    //    __weak typeof(self) wself = self;
    self.userInfoView.hidden = YES;
    [self.contentContainer addSubview:_userInfoView];
    
    self.headerView = [[FHHouseDeatilRGCCellHeader alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    self.headerView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.headerView.imClick = ^{
        [weakSelf clickImAction];
    };
    self.headerView.phoneCilck = ^{
         [weakSelf clickPhoneAction];
    };
    self.headerView.headerClick  = ^{
         [weakSelf clickHeader];
    };
    self.headerView.headerLicenseBlock = ^{
        [weakSelf clickHeaderLicense];
    };
    [self.contentContainer addSubview:_headerView];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin - 30, 0)];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.delegate = self;
    [self.contentContainer addSubview:_contentLabel];
    self.imageViewheight = 200;
    self.imageViewWidth = 150;
    
    
    self.videoImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, self.imageViewWidth, self.imageViewheight)];
    _videoImageView.backgroundColor = [UIColor themeGray7];
    _videoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    _videoImageView.layer.masksToBounds = YES;
    _videoImageView.layer.cornerRadius = 4;
    [self.contentContainer addSubview:_videoImageView];
    
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
    
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin , bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    _bottomView.bottomSepView.hidden = YES;
    _bottomView.marginRight = 8;
    _bottomView.paddingLike = 30;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    [self.contentContainer addSubview:_bottomView];
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin -30, .5)];
    self.lineView.backgroundColor = [UIColor themeGray6];
    [self.contentContainer addSubview:self.lineView];
    
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)initConstraints {
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
}

- (void)layoutViews {
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    
    if(self.cellModel.isInRealtorEvaluationList) {
        self.contentContainer.layer.masksToBounds = YES;
        self.contentContainer.layer.cornerRadius = 10;
    };
    
    [self.contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(cellModel.isInRealtorEvaluationList?15:0);
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(cellModel.isInRealtorEvaluationList?-15:0);
        make.bottom.equalTo(self.contentView).offset(cellModel.isInRealtorEvaluationList?-16:0);
    }];
    
    self.userInfoView.top = cellModel.isInRealtorEvaluationList?18:topMargin;
    self.userInfoView.left = 0;
    self.userInfoView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.userInfoView.height = userInfoViewHeight;
    
    self.headerView.top = cellModel.isInRealtorEvaluationList?18:topMargin;
    self.headerView.left = 0;
    self.headerView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.headerView.height = userInfoViewHeight;
    
    self.contentLabel.top = self.userInfoView.bottom + 7;
    self.contentLabel.left = leftMargin;
    self.contentLabel.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin -30;
    self.contentLabel.height = 0;
    
    self.videoImageView.top = 0;
    self.videoImageView.left =  leftMargin;
    self.videoImageView.width = self.imageViewWidth;
    self.videoImageView.height = self.imageViewheight;
    
    self.bottomView.top = self.videoImageView.bottom + 10;
    self.bottomView.left = 0;
    self.bottomView.width = [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin ;
    self.bottomView.height = bottomViewHeight;
    
    self.lineView.top = self.videoImageView.bottom + 30;
    self.lineView.left = leftMargin;
    self.lineView.width = [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin -30 ;
    self.lineView.height = 0.5;
    
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
        self.contentLabel.height = 0;
        self.videoImageView.top = self.userInfoView.bottom + 10;
    }else{
        self.contentLabel.hidden = NO;
        self.contentLabel.height = cellModel.contentHeight;
        self.videoImageView.top = self.contentLabel.bottom + 10 ;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    self.lineView.top = self.videoImageView.bottom + 30;
    self.bottomView.top = self.videoImageView.bottom + 10;
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
    if (cellModel.realtor) {
        self.userInfoView.hidden = YES;
        self.headerView.hidden = NO;
        [self.headerView refreshWithData:cellModel];
    }else {
        self.userInfoView.hidden = NO;
        self.headerView.hidden = YES;
        [self.userInfoView refreshWithData:cellModel];
    }
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
    
    self.bottomView.hidden = !cellModel.isInRealtorEvaluationList;
    self.lineView.hidden = cellModel.isInRealtorEvaluationList || !cellModel.isShowLineView;
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
        
        self.videoImageView.width = self.imageViewWidth;
        self.videoImageView.height = self.imageViewheight;
        
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
    [self layoutViews];
    

//    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height;
        if (cellModel.isInRealtorEvaluationList) {
            height = cellModel.contentHeight  +150 + 22 + 50 + 130;
        }else {
            height = cellModel.contentHeight  +150 + 10 + 50 + 90;
        }
        return height;
    }
    return 44;
}

- (void)clickHeaderLicense {
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickRealtorIm:cell:)]){
        [self.delegate clickRealtorHeaderLicense:self.cellModel cell:self];
    }
}

- (void)clickImAction {
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickRealtorIm:cell:)]){
        [self.delegate clickRealtorIm:self.cellModel cell:self];
    }
}

- (void)clickPhoneAction {
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickRealtorPhone:cell:)]){
        [self.delegate clickRealtorPhone:self.cellModel cell:self];
    }
}

- (void)clickHeader {
        if(self.delegate && [self.delegate respondsToSelector:@selector(clickRealtorHeader:cell:)]){
        [self.delegate clickRealtorHeader:self.cellModel cell:self];
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
