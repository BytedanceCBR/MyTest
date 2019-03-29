//
//  FHHouseListCommuteTipView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/29.
//

#import "FHHouseListCommuteTipView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <FHHouseBase/FHCommonDefines.h>

#define TIP_HEIGHT 20
#define TIP_TO_BOTTOM 14
#define ACTION_WIDTH 50

@interface FHHouseListCommuteTipView()

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIButton *actionButton;
@property(nonatomic , strong) UIView *bottomLine;

@end

@implementation FHHouseListCommuteTipView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tipLabel = [[UILabel alloc] init];
        
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        _actionButton.titleLabel.font = [UIFont themeFontRegular:14];
        [_actionButton addTarget:self action:@selector(showHideAction) forControlEvents:UIControlEventTouchUpInside];
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
        
        [self addSubview:_tipLabel];
        [self addSubview:_actionButton];
        [self addSubview:_bottomLine];
        
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN);
            make.bottom.mas_equalTo(self).offset(-TIP_TO_BOTTOM);
            make.height.mas_equalTo(TIP_HEIGHT);
            make.right.mas_lessThanOrEqualTo(self.actionButton.mas_left).offset(-10);
        }];
        
        [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-HOR_MARGIN/2);
            make.width.mas_equalTo(ACTION_WIDTH);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self);
            make.height.mas_equalTo(ONE_PIXEL);
        }];
        
        self.showHide = NO;
        
    }
    return self;
    
}

-(void)setShowHide:(BOOL)showHide
{
    _showHide = showHide;
    [self.actionButton setTitle:showHide? @"收起": @"修改" forState:UIControlStateNormal];
}

-(void)showHideAction
{
    if (self.changeOrHideBlock) {
        self.changeOrHideBlock(_showHide);
    }
}

-(void)updateTime:(NSString *)time tip:(NSString *)tip
{
    NSMutableAttributedString *info = [NSMutableAttributedString new];
    if (time.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:14],
                               NSForegroundColorAttributeName:[UIColor themeRed1]
                               };
        NSAttributedString *timeAttr = [[NSAttributedString alloc] initWithString:time attributes:attr ];
        [info appendAttributedString:timeAttr];
    }
    if (tip.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:14],
                               NSForegroundColorAttributeName:[UIColor themeGray2]
                               };
        NSAttributedString *tipAttr = [[NSAttributedString alloc]initWithString:tip attributes:attr];
        [info appendAttributedString:tipAttr];
    }
    
    self.tipLabel.attributedText = info;
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
