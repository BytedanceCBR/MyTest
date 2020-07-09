//
//  FHHouseDeatilRGCImageCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "FHHouseDeatilRGCImageCell.h"
#import "FHHouseDeatilRGCCellHeader.h"
#import "FHHouseDetailRGCMultiImageView.h"
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

@interface FHHouseDeatilRGCImageCell ()<TTUGCAsyncLabelDelegate>
@property(nonatomic ,strong) UIView *contentContainer;
@property (strong, nonatomic) TTUGCAsyncLabel *contentLabel;
@property (strong, nonatomic) FHHouseDetailRGCMultiImageView *multiImageView;
@property (strong, nonatomic) FHUGCCellBottomView *bottomView;
@property (strong, nonatomic) FHHouseDeatilRGCCellHeader *headerView;
@property (strong ,nonatomic) FHUGCCellUserInfoView *userInfoView;
@property (nonatomic ,assign) CGFloat imageViewheight;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property (strong ,nonatomic) FHUGCCellUserInfoView *lineView;

@end
@implementation FHHouseDeatilRGCImageCell
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
    
    self.multiImageView = [[FHHouseDetailRGCMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin -30, 0) count:3];
    [self.contentContainer addSubview:_multiImageView];
    self.imageViewheight = [FHHouseDetailRGCMultiImageView viewHeightForCount:3 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin -30];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin , bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    _bottomView.bottomSepView.hidden = YES;
    _bottomView.marginRight = 8;
    _bottomView.paddingLike = 30;
    [self.contentContainer addSubview:_bottomView];
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin -30, .5)];
    self.lineView.backgroundColor = [UIColor themeGray6];
    [self.contentContainer addSubview:self.lineView];
}

- (void)initConstraints {
    
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
    
    self.userInfoView.top =cellModel.isInRealtorEvaluationList?18:topMargin;
    self.userInfoView.left = 0;
    self.userInfoView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.userInfoView.height = userInfoViewHeight;
    
    self.headerView.top = cellModel.isInRealtorEvaluationList?18:topMargin;
    self.headerView.left = 0;
    self.headerView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    self.headerView.height = userInfoViewHeight;
    
    self.contentLabel.top = self.userInfoView.bottom + 10;
    self.contentLabel.left = leftMargin;
    self.contentLabel.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin -30;
    self.contentLabel.height = 0;
    
    self.multiImageView.top = self.userInfoView.bottom + 7;
    self.multiImageView.left = leftMargin;
    self.multiImageView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin -30;
    self.multiImageView.height = self.imageViewheight;
    
    self.bottomView.top = self.multiImageView.bottom + 15;
    self.bottomView.left = 0;
    self.bottomView.width = [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin ;
    self.bottomView.height = bottomViewHeight;
    
    self.lineView.top = self.multiImageView.bottom + 30;
    self.lineView.left = leftMargin;
    self.lineView.width = [UIScreen mainScreen].bounds.size.width- leftMargin - rightMargin -30 ;
    self.lineView.height = 0.5;
    
    if(isEmptyString(cellModel.content)){
          self.contentLabel.hidden = YES;
          self.contentLabel.height = 0;
          self.multiImageView.top = self.userInfoView.bottom + 10;
      }else{
          self.contentLabel.hidden = NO;
          self.contentLabel.height = cellModel.contentHeight;
          self.multiImageView.top = self.userInfoView.bottom + 10 + cellModel.contentHeight + 10;
          [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
      }
    
    //图片
    [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    
    UIView *lastView = cellModel.imageList.count == 0?self.contentLabel:self.multiImageView;
    CGFloat topOffset = 15;
    self.bottomView.top = lastView.bottom + topOffset;
    self.lineView.top = lastView.bottom + 30;
    //
    //    self.originView.top = self.multiImageView.bottom + 10;
    //    self.originView.left = leftMargin;
    //    self.originView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    //    self.originView.height = originViewHeight;
    //
    //    self.attachCardView.top = self.multiImageView.bottom + 10;
    //    self.attachCardView.left = leftMargin;
    //    self.attachCardView.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
    //    self.attachCardView.height = attachCardViewHeight;
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
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    
    [self initConstraints];
    
    self.bottomView.hidden = !cellModel.isInRealtorEvaluationList;
    
    self.lineView.hidden = cellModel.isInRealtorEvaluationList || !cellModel.isShowLineView;
    
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

// 点击经纪人电话
// 点击经纪人IM

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

- (void)clickHeaderLicense {
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickRealtorIm:cell:)]){
        [self.delegate clickRealtorHeaderLicense:self.cellModel cell:self];
    }
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height;
        if (cellModel.isInRealtorEvaluationList) {
            height =  cellModel.contentHeight  +(cellModel.imageList.count == 0?15:75+ 22)  + 50 + 85;
        }else {
            height =  cellModel.contentHeight  +(cellModel.imageList.count == 0?0:75+ 30)  + 50 + 40;
        }
        return height;
    }
    return 44;
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
