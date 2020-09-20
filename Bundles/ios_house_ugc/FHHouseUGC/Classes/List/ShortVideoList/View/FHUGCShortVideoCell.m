//
//  FHUGCShortVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHUGCShortVideoCell.h"
#import "UIViewAdditions.h"
#import "UIColor+Theme.h"
#import "FHFeedUGCCellModel.h"
#import "UIImageView+fhUgcImage.h"
#import "UIFont+House.h"

@interface FHUGCShortVideoCell ()

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;
@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UIView *blackCoverView;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation FHUGCShortVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)initView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 10;
    
    self.bgView = [[UIImageView alloc] init];
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.backgroundColor = [UIColor themeGray7];
    _bgView.layer.borderWidth = 0.5;
    _bgView.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.contentView addSubview:_bgView];
    
    self.blackCoverView = [[UIView alloc] init];
    _blackCoverView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_ugc_video_mute_bg"]];
//    _blackCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.bgView addSubview:_blackCoverView];

    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 2;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.bgView addSubview:_titleLabel];
//
//    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
//    _descLabel.textAlignment = NSTextAlignmentLeft;
//    [self.bgView addSubview:_descLabel];
//
//    self.tagView = [[FHCornerView alloc] init];
//    _tagView.backgroundColor = [UIColor themeOrange1];
//    _tagView.hidden = YES;
//    [self.bgView addSubview:_tagView];
//
//    self.tagLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
//    [_tagLabel sizeToFit];
//    [_tagLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [_tagLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [_tagView addSubview:_tagLabel];
//
//    self.lookAllLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeOrange1]];
//    _lookAllLabel.textAlignment = NSTextAlignmentRight;
//    _lookAllLabel.text = @"查看全部";
//    _lookAllLabel.layer.masksToBounds = YES;
//    _lookAllLabel.backgroundColor = [UIColor themeOrange2];
//    _lookAllLabel.hidden = YES;
//    [self.bgView addSubview:_lookAllLabel];
//
//    self.lookAllImageView = [[UIImageView alloc] init];
//    _lookAllImageView.image = [UIImage imageNamed:@"fh_ugc_look_all"];
//    _lookAllImageView.hidden = YES;
//    [self.bgView addSubview:_lookAllImageView];
}

- (void)initConstains {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.blackCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.titleLabel.mas_top).offset(-5);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(5);
        make.right.mas_equalTo(self.bgView).offset(-5);
        make.bottom.mas_equalTo(self.bgView).offset(-5);
    }];
//
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.bgView).offset(28);
//        make.left.mas_equalTo(self.bgView).offset(8);
//        make.right.mas_equalTo(self.bgView).offset(-8);
//    }];
//
//    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.bgView).offset(-8);
//        make.left.mas_equalTo(self.bgView).offset(8);
//        make.right.mas_equalTo(self.bgView).offset(-8);
//        make.height.mas_equalTo(14);
//    }];
//
//    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.bgView);
//        make.top.mas_equalTo(self.bgView);
//        make.height.mas_equalTo(15);
//    }];
//
//    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.tagView).offset(7);
//        make.right.mas_equalTo(self.tagView).offset(-7);
//        make.centerY.mas_equalTo(self.tagView);
//        make.height.mas_equalTo(15);
//    }];
//
//    [self.lookAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.bgView).offset(13);
//        make.centerY.mas_equalTo(self.bgView);
//        make.width.mas_equalTo(48);
//        make.height.mas_equalTo(17);
//    }];
//
//    [self.lookAllImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.lookAllLabel.mas_right).offset(4);
//        make.centerY.mas_equalTo(self.lookAllLabel);
//        make.width.height.mas_equalTo(12);
//    }];
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
    //设置userInfo
//    self.userInfoView.cellModel = cellModel;
//    self.userInfoView.userName.text = !isEmptyString(cellModel.user.name) ? cellModel.user.name : @"用户";
//    [self.userInfoView updateDescLabel];
//    [self.userInfoView updateEditState];
//    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
//    [self.userInfoView refreshWithData:cellModel];
    //设置底部
//    self.bottomView.cellModel = cellModel;
    
//    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
//    self.bottomView.position.text = cellModel.community.name;
//    [self.bottomView showPositionView:showCommunity];
    
//    NSInteger commentCount = [cellModel.commentCount integerValue];
//    if(commentCount == 0){
//        [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
//    }else{
//        [self.bottomView.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
//    }
//    [self.bottomView updateLikeState:cellModel.diggCount userDigg:cellModel.userDigg];
    //内容
//    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    //图片
    if (cellModel.imageList.count > 0) {
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        if (imageModel && imageModel.url.length > 0) {
            NSURL *url = [NSURL URLWithString:imageModel.url];
            [self.bgView fh_setImageWithURL:url placeholder:nil reSize:self.contentView.bounds.size];
        }else{
            self.bgView.image = nil;
        }
    }else{
        self.bgView.image = nil;
    }
//    // 时间
//    NSString *timeStr = @"00:00";
//    if (cellModel.videoDuration > 0) {
//        NSInteger minute = cellModel.videoDuration / 60;
//        NSInteger second = cellModel.videoDuration % 60;
//        NSString *mStr = @"00";
//        if (minute < 10) {
//            mStr = [NSString stringWithFormat:@"%02ld",minute];
//        } else {
//            mStr = [NSString stringWithFormat:@"%ld",minute];
//        }
//        NSString *sStr = @"00";
//        if (second < 10) {
//            sStr = [NSString stringWithFormat:@"%02ld",second];
//        } else {
//            sStr = [NSString stringWithFormat:@"%ld",second];
//        }
//        timeStr = [NSString stringWithFormat:@"%@:%@",mStr,sStr];
//    }
//    self.timeLabel.text = timeStr;
//    // [self.timeLabel sizeToFit];
//    [self.timeLabel layoutIfNeeded];
//
    if(isEmptyString(cellModel.content)){
        self.titleLabel.hidden = YES;
        self.titleLabel.text = @"";
    }else{
        self.titleLabel.hidden = NO;
        self.titleLabel.text = cellModel.content;
    }
//
//    self.bottomView.top = self.videoImageView.bottom + 10;
//    [self showGuideView];
}

@end
