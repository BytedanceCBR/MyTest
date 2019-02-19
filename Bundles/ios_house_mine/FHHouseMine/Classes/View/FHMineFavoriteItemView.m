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
#import <UIImageView+BDWebImage.h>

@interface FHMineFavoriteItemView()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *image;

@end

@implementation FHMineFavoriteItemView

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName;
{
    self = [super initWithFrame:CGRectZero];
    if(self){
        _name = name;
        _image = [UIImage imageNamed:imageName];
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self initView];
    [self initConstaints];
}

- (void)initView
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
    [self addGestureRecognizer:tapGesture];
    
    self.nameLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    _nameLabel.text = self.name;
    [self addSubview:_nameLabel];
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.image = self.image;
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconView];
}

- (void)initConstaints
{
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(15);
        make.width.height.mas_equalTo(24*(UIScreen.mainScreen.bounds.size.width/320));
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_bottom).offset(9);
        make.centerX.mas_equalTo(self.iconView);
        make.bottom.equalTo(self).offset(-18);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)viewClicked
{
    if(self.focusClickBlock){
        self.focusClickBlock();
    }
}

@end
