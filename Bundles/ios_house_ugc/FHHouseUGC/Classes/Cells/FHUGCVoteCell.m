//
//  FHUGCVoteCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/8/25.
//

#import "FHUGCVoteCell.h"
#import "FHUGCProgressView.h"

#define bottomSepViewHeight 5

@interface FHUGCVoteCell()

@property(nonatomic, strong) UIView *bottomSepView;
@property(nonatomic, strong) FHUGCProgressView *progressView;
@property(nonatomic, strong) UIButton *testBtn;

@end

@implementation FHUGCVoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.progressView = [[FHUGCProgressView alloc] initWithFrame:CGRectMake(20, 50, [UIScreen mainScreen].bounds.size.width - 40, 30)];
    [self.contentView addSubview:_progressView];
    
    self.testBtn = [[UIButton alloc] init];
    _testBtn.backgroundColor = [UIColor purpleColor];
    [_testBtn setTitle:@"test" forState:UIControlStateNormal];
    [_testBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_testBtn];
//    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
//    [self.contentView addSubview:_userInfoView];
//
//    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
//    _contentLabel.numberOfLines = maxLines;
//    NSDictionary *linkAttributes = @{
//                                     NSForegroundColorAttributeName : [UIColor themeRed1],
//                                     NSFontAttributeName : [UIFont themeFontRegular:16]
//                                     };
//    self.contentLabel.linkAttributes = linkAttributes;
//    self.contentLabel.activeLinkAttributes = linkAttributes;
//    self.contentLabel.inactiveLinkAttributes = linkAttributes;
//    _contentLabel.delegate = self;
//    [self.contentView addSubview:_contentLabel];
//
//    self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:1];
//    _multiImageView.fixedSingleImage = YES;
//    [self.contentView addSubview:_multiImageView];
//    self.imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
//
//    self.originView = [[FHUGCCellOriginItemView alloc] initWithFrame:CGRectZero];
//    _originView.hidden = YES;
//    [self.contentView addSubview:_originView];
//
//    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
//    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:_bottomView];
//
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
//    [self.bottomView.positionView addGestureRecognizer:tap];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
//    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentView).offset(20);
//        make.left.right.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(40);
//    }];
//
//    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
//        make.left.mas_equalTo(self.contentView).offset(leftMargin);
//        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
//    }];
//
//    [self.multiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
//        make.left.mas_equalTo(self.contentView).offset(leftMargin);
//        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
//        make.height.mas_equalTo(self.imageViewheight);
//    }];
//
//    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.multiImageView.mas_bottom).offset(10);
//        make.height.mas_equalTo(49);
//        make.left.right.mas_equalTo(self.contentView);
//    }];
//
//    [self.originView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.multiImageView.mas_bottom).offset(10);
//        make.height.mas_equalTo(originViewHeight);
//        make.left.mas_equalTo(self.contentView).offset(leftMargin);
//        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
//    }];
    [self.testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.bottomSepView.mas_top).offset(-20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(bottomSepViewHeight);
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
    
//    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
//    self.cellModel = cellModel;
//    //设置userInfo
//    self.userInfoView.cellModel = cellModel;
//    self.userInfoView.userName.text = cellModel.user.name;
//    self.userInfoView.descLabel.attributedText = cellModel.desc;
//    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
//    //设置底部
//    self.bottomView.cellModel = cellModel;
//
//    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
//    self.bottomView.position.text = cellModel.community.name;
//    [self.bottomView showPositionView:showCommunity];
//
//    NSInteger commentCount = [cellModel.commentCount integerValue];
//    if(commentCount == 0){
//        [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
//    }else{
//        [self.bottomView.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
//    }
//    [self.bottomView updateLikeState:cellModel.diggCount userDigg:cellModel.userDigg];
//    //内容
//    self.contentLabel.numberOfLines = cellModel.numberOfLines;
//    if(isEmptyString(cellModel.content)){
//        self.contentLabel.hidden = YES;
//        [self.multiImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
//            make.left.mas_equalTo(self.contentView).offset(leftMargin);
//            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
//            make.height.mas_equalTo(self.imageViewheight);
//        }];
//    }else{
//        self.contentLabel.hidden = NO;
//        [self.multiImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
//            make.left.mas_equalTo(self.contentView).offset(leftMargin);
//            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
//            make.height.mas_equalTo(self.imageViewheight);
//        }];
//        [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel];
//    }
//    //图片
//    [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
//    //origin
//    if(cellModel.originItemModel){
//        self.originView.hidden = NO;
//        [self.originView refreshWithdata:cellModel];
//        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.multiImageView.mas_bottom).offset(originViewHeight + 20);
//        }];
//    }else{
//        self.originView.hidden = YES;
//        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.multiImageView.mas_bottom).offset(10);
//        }];
//    }
//
//    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
//    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
//        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
//        CGFloat height = cellModel.contentHeight + userInfoViewHeight + bottomViewHeight + topMargin + 30;
//
//        if(isEmptyString(cellModel.content)){
//            height -= 10;
//        }
//
//        CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
//        height += imageViewheight;
//
//        if(cellModel.originItemModel){
//            height += (originViewHeight + 10);
//        }
//
//        if(cellModel.isInsertGuideCell){
//            height += guideViewHeight;
//        }
//
//        return height;
//    }
    return 200;
}

- (void)test {
    self.progressView.progress = 0.3;
    self.progressView.isRightGradient = YES;
    self.progressView.rightStartColor = [UIColor blueColor];
    self.progressView.rightEndColor = [UIColor themeBlue1];
}

@end
