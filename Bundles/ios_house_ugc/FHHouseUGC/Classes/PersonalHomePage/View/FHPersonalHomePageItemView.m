//
//  FHPersonalHomePageItemView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHPersonalHomePageItemView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"

@interface FHPersonalHomePageItemView ()

@property(nonatomic, strong) UILabel *topLabel;
@property(nonatomic, strong) UILabel *bottomLabel;
@property(nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation FHPersonalHomePageItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    
    self.topLabel = [self LabelWithFont:[UIFont themeFontDINAlternateBold:18] textColor:[UIColor themeGray1]];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.text = @"110";
    [self addSubview:_topLabel];
    
    self.bottomLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray2]];
    _bottomLabel.textAlignment = NSTextAlignmentCenter;
    _bottomLabel.text = @"评论";
    [self addSubview:_bottomLabel];
}

- (void)initConstraints {
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(21);
    }];
    
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLabel.mas_bottom);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(17);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateWithTopContent:(NSString *)topContent bottomContent:(NSString *)bottomContent {
    self.topLabel.text = topContent;
    self.bottomLabel.text = bottomContent;
}

- (void)setItemClickBlock:(void (^)(void))itemClickBlock {
    if(itemClickBlock){
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.tap];
        _itemClickBlock = itemClickBlock;
    }else{
        self.userInteractionEnabled = NO;
        [self removeGestureRecognizer:self.tap];
        _itemClickBlock = nil;
    }
}

- (UITapGestureRecognizer *)tap {
    if(!_tap){
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClicked)];
    }
    return _tap;
}

- (void)itemClicked {
    if(self.itemClickBlock){
        self.itemClickBlock();
    }
}

@end
