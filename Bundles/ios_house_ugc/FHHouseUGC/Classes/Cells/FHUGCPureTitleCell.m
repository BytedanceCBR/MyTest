//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCPureTitleCell.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import <UIImageView+BDWebImage.h>
#import "TTUGCAttributedLabel.h"
#import "FHUGCCellHelper.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 5

@interface FHUGCPureTitleCell ()

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHUGCPureTitleCell

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
    __weak typeof(self) wself = self;
    _userInfoView.deleteCellBlock = ^{
        [wself deleteCell];
    };
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_contentLabel];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_bottomView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
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
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(30);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(20);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        //设置userInfo
        self.userInfoView.cellModel = cellModel;
        self.userInfoView.userName.text = cellModel.user.name;
        self.userInfoView.descLabel.attributedText = cellModel.desc;
        [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
        //设置底部
        self.bottomView.cellModel = cellModel;
        self.bottomView.position.text = @"左家庄";
        [self.bottomView.commentBtn setTitle:cellModel.commentCount forState:UIControlStateNormal];
        [self.bottomView updateLikeState:cellModel.diggCount userDigg:cellModel.userDigg];
        //内容
        [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel numberOfLines:maxLines];
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

@end
