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
#import <FHCornerView.h>

@interface FHUGCHotCommunitySubCell ()

@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;

@property(nonatomic ,strong) UILabel *tagLabel;
@property(nonatomic ,strong) FHCornerView *tagView;

//查看全部
@property(nonatomic ,strong) UILabel *lookAllLabel;
@property(nonatomic ,strong) UIImageView *lookAllImageView;

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
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor blackColor]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _titleLabel.numberOfLines = 2;
//    _titleLabel.text = @"#幸福攻略";
    [self.bgView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor blackColor]];
    _descLabel.textAlignment = NSTextAlignmentLeft;
//    _descLabel.text = @"20218人参与";
    [self.bgView addSubview:_descLabel];
    
    self.tagView = [[FHCornerView alloc] init];
    _tagView.backgroundColor = [UIColor themeOrange1];
    _tagView.hidden = YES;
    [self.bgView addSubview:_tagView];
    
    self.tagLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
    [_tagLabel sizeToFit];
    _tagLabel.text = @"新";
    [_tagLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_tagLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_tagView addSubview:_tagLabel];
    
    self.lookAllLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeOrange1]];
    _lookAllLabel.textAlignment = NSTextAlignmentRight;
    _lookAllLabel.text = @"查看全部";
    [self.bgView addSubview:_lookAllLabel];
    
    self.lookAllImageView = [[UIImageView alloc] init];
    _lookAllImageView.image = [UIImage imageNamed:@"fh_ugc_look_all"];
    [self.bgView addSubview:_lookAllImageView];
}

- (void)initConstains {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(28);
        make.left.mas_equalTo(self.bgView).offset(8);
        make.right.mas_equalTo(self.bgView).offset(-8);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bgView).offset(-8);
        make.left.mas_equalTo(self.bgView).offset(8);
        make.right.mas_equalTo(self.bgView).offset(-8);
        make.height.mas_equalTo(14);
    }];
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bgView);
        make.height.mas_equalTo(15);
    }];
    
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tagView).offset(7);
        make.right.mas_equalTo(self.tagView).offset(-7);
        make.centerY.mas_equalTo(self.tagView);
        make.height.mas_equalTo(15);
    }];
    
    [self.lookAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(13);
        make.centerY.mas_equalTo(self.bgView);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(17);
    }];
    
    [self.lookAllImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lookAllLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.lookAllLabel);
        make.width.height.mas_equalTo(12);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
