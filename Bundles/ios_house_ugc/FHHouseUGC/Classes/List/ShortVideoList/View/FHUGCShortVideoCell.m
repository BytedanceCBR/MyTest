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
@property (nonatomic ,strong) CAGradientLayer *gradientLayer;

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
    self.bgView = [[UIImageView alloc] init];
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.backgroundColor = [UIColor themeGray7];
    _bgView.layer.borderWidth = 0.5;
    _bgView.layer.borderColor = [[UIColor themeGray6] CGColor];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 10;
    [self.contentView addSubview:_bgView];
    
    self.blackCoverView = [[UIView alloc] init];
    [self.bgView addSubview:_blackCoverView];

    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 2;
    [self.bgView addSubview:_titleLabel];
}

- (void)initConstains {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.blackCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(64);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(10);
        make.right.mas_equalTo(self.bgView).offset(-10);
        make.bottom.mas_equalTo(self.bgView).offset(-10);
    }];

    [self.contentView layoutIfNeeded];
    //背景渐变
    self.gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.blackCoverView.bounds;
    _gradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                              (id)[[UIColor blackColor] colorWithAlphaComponent:0.56].CGColor];
    [self.blackCoverView.layer addSublayer:_gradientLayer];
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

    if(isEmptyString(cellModel.content)){
        self.titleLabel.hidden = YES;
        self.titleLabel.text = @"";
    }else{
        self.titleLabel.hidden = NO;
        self.titleLabel.text = cellModel.content;
    }
}

@end
