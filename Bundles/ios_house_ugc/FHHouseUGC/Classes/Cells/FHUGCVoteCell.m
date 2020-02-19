//
//  FHUGCVoteCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/8/25.
//

#import "FHUGCVoteCell.h"
#import "FHUGCProgressView.h"
//#import "TTRoute.h"

#define bottomSepViewHeight 5

@interface FHUGCVoteCell()

@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UIView *bgShadowView;
@property(nonatomic, strong) UIView *bottomSepView;

@property(nonatomic, strong) UIImageView *titleImageView;
@property(nonatomic, strong) UIButton *moreBtn;
//@property(nonatomic, strong) UILabel *personLabel;
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
    
    self.bgShadowView = [[UIView alloc] init];
    _bgShadowView.backgroundColor = [UIColor whiteColor];
    _bgShadowView.layer.shadowColor = [UIColor colorWithHexString:@"bab8b8"].CGColor;//阴影颜色
    _bgShadowView.layer.shadowOffset = CGSizeMake(0, 7);//阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    _bgShadowView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    _bgShadowView.layer.shadowRadius = 7;//阴影半径，默认3
    [self.contentView addSubview:_bgShadowView];
    
    self.bgView = [[UIImageView alloc] init];
    _bgView.userInteractionEnabled = YES;
    _bgView.image = [UIImage imageNamed:@"fh_ugc_vote_bg"];
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 4;
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
    [_moreBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    //文字的size
    CGSize textSize = [_moreBtn.titleLabel.text sizeWithFont:_moreBtn.titleLabel.font];
    CGSize imageSize = _moreBtn.currentImage.size;
    _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, textSize.width + 2 - imageSize.width, 0, - textSize.width - 2 + imageSize.width);
    _moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width - 6, 0, imageSize.width + 6);
    //设置按钮内容靠右
    _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.bgView addSubview:_moreBtn];
    
//    self.personLabel = [[UILabel alloc] init];
//    _personLabel.textColor = [UIColor themeGray3];
//    _personLabel.font = [UIFont themeFontMedium:10];
//    [self.bgView addSubview:_personLabel];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 2;
    [self.bgView addSubview:_contentLabel];
    
    self.voteView = [[UIView alloc] init]; 
    [self.bgView addSubview:_voteView];

    self.leftBtn = [[UIButton alloc] init];
    [_leftBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_vote_left"] forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_vote_left"] forState:UIControlStateHighlighted];
    _leftBtn.titleLabel.font = [UIFont themeFontMedium:16];
    [_leftBtn addTarget:self action:@selector(goToDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.voteView addSubview:_leftBtn];
    
    self.rightBtn = [[UIButton alloc] init];
    [_rightBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_vote_right"] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_vote_right"] forState:UIControlStateHighlighted];
    _rightBtn.titleLabel.font = [UIFont themeFontMedium:16];
    [_rightBtn addTarget:self action:@selector(goToDetail:) forControlEvents:UIControlEventTouchUpInside];
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
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.bottom.mas_equalTo(self.bottomSepView.mas_top).offset(-20);
    }];
    
    [self.bgShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(10);
        make.left.mas_equalTo(self.bgView).offset(10);
        make.right.mas_equalTo(self.bgView).offset(-10);
        make.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(20);
        make.left.mas_equalTo(self.bgView).offset(20);
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(14);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleImageView);
        make.right.mas_equalTo(self.bgView).offset(-20);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleImageView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.titleImageView.mas_left).offset(-1);
        make.right.mas_equalTo(self.moreBtn.mas_right).offset(1);
        make.height.mas_equalTo(22);
    }];
    
//    [self.personLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(9);
//        make.centerX.mas_equalTo(self.bgView);
//        make.height.mas_equalTo(12);
//    }];

    [self.voteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.leftBtn);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(24);
        make.centerX.mas_equalTo(self.voteView);
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.icon.mas_left).offset(-10);
        make.top.mas_equalTo(self.voteView).offset(15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(35);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.centerY.mas_equalTo(self.leftBtn);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(35);
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
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    //内容
    self.contentLabel.attributedText = cellModel.vote.contentAStr;
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellModel.vote.contentHeight);
    }];
    //讨论人数
//    self.personLabel.attributedText = [self generatePersonCount:cellModel.vote.personDesc];
    //选项
    [self.leftBtn setTitle:cellModel.vote.leftDesc forState:UIControlStateNormal];
    [self.rightBtn setTitle:cellModel.vote.rightDesc forState:UIControlStateNormal];
    self.leftBtn.tag = [cellModel.vote.leftValue integerValue];
    self.rightBtn.tag = [cellModel.vote.rightValue integerValue];
    
    if(cellModel.vote.leftDesc.length > 4 || cellModel.vote.rightDesc.length > 4){
        _leftBtn.titleLabel.font = [UIFont themeFontMedium:14];
        _rightBtn.titleLabel.font = [UIFont themeFontMedium:14];
    }else{
        _leftBtn.titleLabel.font = [UIFont themeFontMedium:16];
        _rightBtn.titleLabel.font = [UIFont themeFontMedium:16];
    }
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = 158 + cellModel.vote.contentHeight;
        return height;
    }
    return 180;
}

- (void)goToDetail:(id)sender {
    UIButton *btn = (UIButton *)sender;
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToVoteDetail:value:)]){
        [self.delegate goToVoteDetail:cellModel value:btn.tag];
    }
}

- (NSAttributedString *)generatePersonCount:(NSString *)text {
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if(!isEmptyString(text)){
        NSString *str = [NSString stringWithFormat:@" %@",text];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -1.7, 12, 12);
        attachment.image = [UIImage imageNamed:@"fh_ugc_vote_person"];
        NSAttributedString *attachmentAStr = [NSAttributedString attributedStringWithAttachment:attachment];
        [desc appendAttributedString:attachmentAStr];
        
        NSAttributedString *distanceAStr = [[NSAttributedString alloc] initWithString:str];
        [desc appendAttributedString:distanceAStr];
    }
    
    return desc;
}

@end
