//
//  FHUGCEncyclopediasCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/4/27.
//

#import "FHUGCEncyclopediasCell.h"
#import "FHUGCCellUserInfoView.h"
#import "UIFont+House.h"
#import "FHUGCCellHelper.h"
#import "UIImageView+BDWebImage.h"
#import "UIViewAdditions.h"

#define iconWidth 120
#define iconHeight 90
#define sidesMargin 20
#define maxLines 3
@interface FHUGCEncyclopediasCell () <TTUGCAttributedLabelDelegate>
@property (weak, nonatomic)FHUGCCellUserInfoView *titleView;
@property (weak, nonatomic)TTUGCAttributedLabel *contentLab;
@property (weak, nonatomic) UIImageView *iconImage;
@property (strong, nonatomic) FHFeedUGCCellModel *cellModel;
@property (strong, nonatomic) UIButton *moreBtn;
@property(nonatomic ,strong) UIView *bottomSepView;
@end
@implementation FHUGCEncyclopediasCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
//    self.titleView.top = self.contentView.top +20;
//    self.titleView.width = [UIScreen mainScreen].bounds.size.width;
//    self.titleView.right = self.contentView.right;
//    self.titleView.height = 40;
    
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(20);
        make.height.mas_offset(40);
    }];
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom).offset(10);
        make.right.equalTo(self.contentView).mas_offset(-sidesMargin);
        make.size.mas_equalTo(CGSizeMake(iconWidth, 90));
    }];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImage);
        make.right.equalTo(self.iconImage.mas_left).offset(-15);
        make.left.equalTo(self.contentView).offset(20);
    }];
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self.contentView);
        make.height.mas_offset(5);
    }];
}

- (FHUGCCellUserInfoView *)titleView {
    if (!_titleView) {
        FHUGCCellUserInfoView *titleView = [[FHUGCCellUserInfoView alloc]init];
        titleView.backgroundColor = [UIColor whiteColor];
        [titleView updateMoreBtnWithTitleType];
        [self.contentView addSubview:titleView];
        _titleView = titleView;
    }
    return  _titleView;
}

- (UIImageView *)iconImage {
    if (!_iconImage) {
        UIImageView *iconImage = [[UIImageView alloc]init];
        iconImage.backgroundColor = [UIColor whiteColor];
        iconImage.layer.cornerRadius = 4;
        iconImage.layer.borderColor = [UIColor themeGray6].CGColor;
        iconImage.layer.borderWidth = 0.5;
        iconImage.layer.masksToBounds = YES;
        [self.contentView addSubview:iconImage];
        _iconImage = iconImage;
    }
    return _iconImage;
}

- (TTUGCAttributedLabel *)contentLab {
    if (!_contentLab) {
        TTUGCAttributedLabel *contentLab = [[TTUGCAttributedLabel alloc]initWithFrame:CGRectZero];
        contentLab.numberOfLines = maxLines;
        contentLab.layer.masksToBounds = YES;
        contentLab.delegate = self;
        contentLab.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:contentLab];
        _contentLab = contentLab;
    }
    return _contentLab;
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        CGFloat height;
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        height  =  (cellModel.avatar.length>0 ?iconHeight:(cellModel.contentHeight+20)) + 40 +sidesMargin *2  + 20;
        return height;
    }
    return 100;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
    if(self.currentData == data && !model.ischanged){
        return;
    }
    self.currentData = data;
    self.cellModel = model;
    [self.titleView.icon bd_setImageWithURL:[NSURL URLWithString:model.user.avatarUrl]];
    self.titleView.userName.text = model.user.name;
    self.titleView.descLabel.text = model.articleTitle;
    self.titleView.cellModel = model;
    self.contentLab.hidden = isEmptyString(model.content);
    [FHUGCCellHelper setRichContent:self.contentLab model:model];
    self.contentLab.height = model.contentHeight;
    self.iconImage.hidden  = isEmptyString(model.avatar);
    [self.iconImage bd_setImageWithURL:[NSURL URLWithString:model.avatar]];
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
