//
//  FHCommuteTypeView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHCommuteTypeView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>

#define BUTTON_HEIGHT 30

@interface FHCommuteTypeView ()

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) NSArray *buttons;
@property(nonatomic , assign) FHCommuteType currentType;

@end


@implementation FHCommuteTypeView

+(CGFloat)cellWidth {
    CGFloat collectionViewWidth = [UIScreen mainScreen].bounds.size.width - HOR_MARGIN * 2;
    // 75 * 4 + 9 * 3  每行显示4个晒选项，每个晒选项间隔9像素
    if (327 > collectionViewWidth) {
        return (collectionViewWidth - 9 * 2) / 3;
    }
    return 75;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.text = @"常用出行方式";
        [self addSubview:_titleLabel];
        
        NSMutableArray* buttons = [NSMutableArray new];
        
        UIButton *button;
        NSArray *names = @[@"公交",@"驾车",@"步行",@"骑车"];
        for (NSInteger i = 0 ; i < 4; i++) {
            button = [self button];
            button.tag = i;
            [button setTitle:names[i] forState:UIControlStateNormal];
            [self addSubview:button];
            [buttons addObject:button];
        }
        _buttons = buttons;
        
        [self initConstraints];
    }
    return self;
}

-(void)initConstraints
{
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(self);
        make.right.mas_lessThanOrEqualTo(-HOR_MARGIN);
        make.height.mas_equalTo(24);
    }];
    
    CGFloat cellWidth = [FHCommuteTypeView cellWidth];
    CGFloat padding = (CGRectGetWidth(self.bounds) - 4*cellWidth - 2*HOR_MARGIN)/3;
    
    UIButton *button;
    for (NSInteger i = 0 ; i < _buttons.count ; i++) {
        button = _buttons[i];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN+(cellWidth + padding)*i);
            make.bottom.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(cellWidth, BUTTON_HEIGHT));
        }];
    }
}

-(void)chooseType:(FHCommuteType)type
{
    _currentType = type;
    [self updateSelectType];
}

-(FHCommuteType)currentType
{
    return _currentType;
}



-(UIButton *)button
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

    button.titleLabel.font = [UIFont themeFontRegular:12];
    
    [button addTarget:self
               action:@selector(typeTapAction:)
     forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    
    
    return button;
    
}

-(void)typeTapAction:(UIButton *)button
{
    _currentType = button.tag;
    [self updateSelectType];
    if (_updateType) {
        _updateType(_currentType);
    }
}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    CGFloat cellWidth = [FHCommuteTypeView cellWidth];
//    CGFloat padding = (CGRectGetWidth(self.bounds) - 4*cellWidth - 2*HOR_MARGIN)/3;
//
//    UIButton *button;
//    for (NSInteger i = 0 ; i < _buttons.count ; i++) {
//        button = _buttons[i];
//        button.frame = CGRectMake(HOR_MARGIN+(cellWidth + padding)*i, self.bounds.size.height - BUTTON_HEIGHT, cellWidth, BUTTON_HEIGHT);
//    }
//
//    
//}

-(void)updateSelectType
{
    UIButton *button;
    for (NSInteger i = 0 ; i < _buttons.count ; i++) {
        button = _buttons[i];
        button.selected = (_currentType == i);
        button.backgroundColor = (button.selected?[UIColor themeRed1]:[UIColor themeGray7]);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
