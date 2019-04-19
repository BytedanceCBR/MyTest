//
//  FHCommuteItemHeader.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import "FHCommuteItemHeader.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <Masonry/Masonry.h>


@implementation FHCommuteItemHeader

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontMedium:14];
        _tipLabel.textColor = [UIColor themeGray1];
        
        [self addSubview:_tipLabel];
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN);
            make.right.mas_lessThanOrEqualTo(self).offset(-HOR_MARGIN);
            make.bottom.mas_equalTo(self);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

-(void)setTip:(NSString *)tip
{
    _tipLabel.text = tip;
}

-(NSString *)tip
{
    return _tipLabel.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
