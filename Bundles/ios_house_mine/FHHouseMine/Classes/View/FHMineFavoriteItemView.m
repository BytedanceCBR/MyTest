//
//  FHMineFavoriteItemView.m
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/13.
//

#import "FHMineFavoriteItemView.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIImageView+BDWebImage.h"

#define labelFontSize ((CGRectGetWidth([UIScreen mainScreen].bounds) > 320) ? 12 : 10)

@interface FHMineFavoriteItemView()

@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSString *imageName;
@property (assign, nonatomic) FHMineModuleType moduleType;
@end

@implementation FHMineFavoriteItemView

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName  moduletype:(FHMineModuleType )moduleType {
    self = [super initWithFrame:CGRectZero];
    if(self){
        _name = name;
        _imageName = imageName;
        _moduleType = moduleType;
        [self setupUI];
    }
    return self;
}

//- (void)setFocusConut:(NSString *)focusConut {
//    _focusConut = focusConut;
//    if ([focusConut isEqual:@""]) {
//        focusConut = @"*";
//    }
//    [(UILabel *)self.iconView setText:focusConut];
//}

- (void)setupUI {
    [self initView];
    [self initConstaints];
}

- (void)initView {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
    [self addGestureRecognizer:tapGesture];
    
    self.nameLabel = [self LabelWithFont:[UIFont themeFontRegular:labelFontSize] textColor:[UIColor themeGray2]];
    _nameLabel.text = self.name;
    [self addSubview:_nameLabel];
    //改版
//    if (self.moduleType == FHMineModuleTypeHouseFocus) {
//        self.iconView = [[UILabel alloc] init];
//        [(UILabel *)_iconView setText:self.focusConut];
//        [(UILabel *)_iconView setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:24]];
//        [(UILabel *)_iconView setTextAlignment:NSTextAlignmentCenter];
//
//    } else {
        self.iconView = [[UIImageView alloc] init];
        _iconView.backgroundColor = [UIColor clearColor];
        [(UIImageView *)self.iconView bd_setImageWithURL:[NSURL URLWithString:_imageName] placeholder:nil];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;

//    }
    [self addSubview:_iconView];

}

- (void)initConstaints {
    CGFloat H = _moduleType == FHMineModuleTypeHouseFocus?56:34;
//    CGFloat W = 24;
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(8);
        make.height.width.mas_equalTo(H*(UIScreen.mainScreen.bounds.size.width/375));
//        make.width.mas_equalTo(W*(UIScreen.mainScreen.bounds.size.width/375));
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_bottom).offset(-2);
        make.centerX.mas_equalTo(self.iconView);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self).offset(-10);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)viewClicked {
    if(self.itemClickBlock){
        self.itemClickBlock();
    }
}

@end
