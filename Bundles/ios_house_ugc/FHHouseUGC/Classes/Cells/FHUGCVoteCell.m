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

@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIView *bottomSepView;

@property(nonatomic, strong) UIImageView *titleImageView;
@property(nonatomic, strong) UIButton *moreBtn;
@property(nonatomic, strong) UILabel *personLabel;
@property(nonatomic, strong) UILabel *contentLabel;



@property(nonatomic, strong) UIView *voteView;
@property(nonatomic, strong) UIButton *leftBtn;
@property(nonatomic, strong) UIButton *rightBtn;
@property(nonatomic, strong) UIImageView *icon;

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
    
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    [self.contentView addSubview:_bgView];
    
    self.titleImageView = [[UIImageView alloc] init];
    _titleImageView.image = [UIImage imageNamed:@"fh_ugc_vote_title"];
    [self.bgView addSubview:_titleImageView];
    
    self.moreBtn = [[UIButton alloc] init];
    _moreBtn.enabled = NO;
    _moreBtn.backgroundColor = [UIColor colorWithHexString:@"ced8e3"];
    _moreBtn.layer.masksToBounds = YES;
    _moreBtn.layer.cornerRadius = 8.5;
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_vote_right_arror"] forState:UIControlStateNormal];
    [_moreBtn setTitle:@"更多" forState:UIControlStateNormal];
    [_moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _moreBtn.titleLabel.font = [UIFont themeFontRegular:10];
    //文字的size
    CGSize textSize = [_moreBtn.titleLabel.text sizeWithFont:_moreBtn.titleLabel.font];
    CGSize imageSize = _moreBtn.currentImage.size;
    _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, textSize.width + 2 - imageSize.width, 0, - textSize.width - 2 + imageSize.width);
    _moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width - 6, 0, imageSize.width + 6);
    //设置按钮内容靠右
    _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self addSubview:_moreBtn];
    
    self.personLabel = [[UILabel alloc] init];
    _personLabel.attributedText = [self generatePersonCount:@"37842人参与"];
    _personLabel.textColor = [UIColor themeGray3];
    _personLabel.font = [UIFont themeFontRegular:10];
    [self.bgView addSubview:_personLabel];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    _contentLabel.text = @"你会为了买房，生活中降低生活品质吗？";
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.numberOfLines = 2;
    [self.bgView addSubview:_contentLabel];
    
    self.voteView = [[UIView alloc] init];
    [self.bgView addSubview:_voteView];

    self.leftBtn = [[UIButton alloc] init];
    _leftBtn.backgroundColor = [UIColor purpleColor];
    [_leftBtn setTitle:@"会" forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.voteView addSubview:_leftBtn];
    
    self.rightBtn = [[UIButton alloc] init];
    _rightBtn.backgroundColor = [UIColor purpleColor];
    [_rightBtn setTitle:@"不会" forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.voteView addSubview:_rightBtn];
    
    self.icon = [[UIImageView alloc] init];
    _icon.image = [UIImage imageNamed:@"fh_ugc_vote_vs"];
    [self.voteView addSubview:_icon];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(19);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.bottom.mas_equalTo(self.bottomSepView.mas_top).offset(-19);
    }];
    
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(16);
        make.left.mas_equalTo(self.bgView).offset(20);
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(14);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(13);
        make.right.mas_equalTo(self.bgView).offset(-20);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleImageView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.bgView).offset(20);
        make.right.mas_equalTo(self.bgView).offset(-20);
        make.height.mas_equalTo(22);
    }];
    
    [self.personLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(9);
        make.centerX.mas_equalTo(self.bgView);
        make.height.mas_equalTo(12);
    }];

    [self.voteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.personLabel.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.voteView).offset(17);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(24);
        make.centerX.mas_equalTo(self.voteView);
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.icon.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.icon);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.centerY.mas_equalTo(self.icon);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
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
    return 191;
}

- (void)test {
//    self.progressView.progress = 0.3;
//    self.progressView.offset = 5;
//    self.progressView.isRightGradient = YES;
//    self.progressView.leftColor = [UIColor redColor];
//    self.progressView.rightStartColor = [UIColor blueColor];
//    self.progressView.rightEndColor = [UIColor themeBlue1];
}

- (NSAttributedString *)generatePersonCount:(NSString *)text {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSString *str = [NSString stringWithFormat:@" %@",text];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, -1.7, 12, 12);
    attachment.image = [UIImage imageNamed:@"fh_ugc_vote_person"];
    NSAttributedString *attachmentAStr = [NSAttributedString attributedStringWithAttachment:attachment];
    [desc appendAttributedString:attachmentAStr];
    
    NSAttributedString *distanceAStr = [[NSAttributedString alloc] initWithString:str];
    [desc appendAttributedString:distanceAStr];
    
    return desc;
}

@end
