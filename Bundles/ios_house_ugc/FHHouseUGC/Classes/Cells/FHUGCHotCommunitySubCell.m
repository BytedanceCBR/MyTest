//
//  FHUGCHotCommunitySubCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/10.
//

#import "FHUGCHotCommunitySubCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import "FHUGCModel.h"

@interface FHUGCHotCommunitySubCell ()

@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UIView *bgCoverView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;

@end

@implementation FHUGCHotCommunitySubCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)refreshWithData:(id)data index:(NSInteger)index {
    //首先处理背景色
    
    
//    if([data isKindOfClass:[FHFeedContentRawDataHotTopicListModel class]]){
//        FHFeedContentRawDataHotTopicListModel *model = (FHUGCScialGroupDataModel *)data;
//        _titleLabel.text = model.forumName;
//        _descLabel.text = model.talkCountStr;
//        [self.bgView bd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholder:nil];
//    }
}

- (void)initView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.bgView = [[UIImageView alloc] init];
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 4;
    _bgView.backgroundColor = [UIColor themeGray7];
    _bgView.layer.borderWidth = 0.5;
    _bgView.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.contentView addSubview:_bgView];
    
    self.bgCoverView = [[UIView alloc] init];
    _bgCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.bgView addSubview:_bgCoverView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 3;
    [self.bgView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    [self.bgView addSubview:_descLabel];
}

- (void)initConstains {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.bgCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bgView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(8);
        make.left.mas_equalTo(self.bgView).offset(8);
        make.right.mas_equalTo(self.bgView).offset(-8);
        make.height.mas_lessThanOrEqualTo(60);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bgView).offset(-8);
        make.left.mas_equalTo(self.bgView).offset(8);
        make.right.mas_equalTo(self.bgView).offset(-8);
        make.height.mas_equalTo(14);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
