//
//  FHUGCHotCommunitySubCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/10.
//

#import "FHUGCHotCommunitySubCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCModel.h"
#import "FHCornerView.h"
#import "FHUGCHotCommunityCell.h"

@interface FHUGCHotCommunitySubCell ()

@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UIView *blackCoverView;
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

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedContentRawDataHotCellListModel class]]){
        FHFeedContentRawDataHotCellListModel *model = (FHFeedContentRawDataHotCellListModel *)data;
        _titleLabel.text = model.title;
        _descLabel.text = model.desc;
        [self.bgView bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
        
        if(model.tips){
            _tagView.hidden = NO;
            _tagLabel.text = model.tips.content;
            _tagView.backgroundColor = [UIColor colorWithHexString:model.tips.color];
        }else{
            _tagView.hidden = YES;
        }
        
        if([model.hotCellType isEqualToString:youwenbida]){
            _bgView.backgroundColor = [UIColor themeGray7];
            _blackCoverView.hidden = YES;
            _titleLabel.hidden = YES;
            _descLabel.hidden = YES;
            _lookAllLabel.hidden = YES;
            _lookAllImageView.hidden = YES;
        }else if([model.hotCellType isEqualToString:more]){
            _bgView.backgroundColor = [UIColor themeOrange2];
            _blackCoverView.hidden = YES;
            _titleLabel.hidden = YES;
            _descLabel.hidden = YES;
            _lookAllLabel.hidden = NO;
            _lookAllImageView.hidden = NO;
            _lookAllLabel.text = model.title;
        }else{
            _bgView.backgroundColor = [UIColor themeGray7];
            _blackCoverView.hidden = NO;
            _titleLabel.hidden = NO;
            _descLabel.hidden = NO;
            _lookAllLabel.hidden = YES;
            _lookAllImageView.hidden = YES;
        }
    }
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
    
    self.blackCoverView = [[UIView alloc] init];
    _blackCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    _blackCoverView.hidden = YES;
    [self.bgView addSubview:_blackCoverView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 2;
    [self.bgView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    [self.bgView addSubview:_descLabel];
    
    self.tagView = [[FHCornerView alloc] init];
    _tagView.backgroundColor = [UIColor themeOrange1];
    _tagView.hidden = YES;
    [self.bgView addSubview:_tagView];
    
    self.tagLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
    [_tagLabel sizeToFit];
    [_tagLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_tagLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_tagView addSubview:_tagLabel];
    
    self.lookAllLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeOrange1]];
    _lookAllLabel.textAlignment = NSTextAlignmentRight;
    _lookAllLabel.text = @"查看全部";
    _lookAllLabel.hidden = YES;
    [self.bgView addSubview:_lookAllLabel];
    
    self.lookAllImageView = [[UIImageView alloc] init];
    _lookAllImageView.image = [UIImage imageNamed:@"fh_ugc_look_all"];
    _lookAllImageView.hidden = YES;
    [self.bgView addSubview:_lookAllImageView];
}

- (void)initConstains {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.blackCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
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
