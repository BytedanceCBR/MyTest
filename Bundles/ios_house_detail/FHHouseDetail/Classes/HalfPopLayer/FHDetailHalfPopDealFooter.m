//
//  FHDetailHalfPopDealFooter.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/22.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopDealFooter.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <FHHouseBase/FHCommonDefines.h>

@implementation FHDetailHalfPopDealFooter

+(CGFloat)heightForText:(NSString *)text
{
    if (text.length == 0) {
        return 0;
    }
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:12]};
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    return ceil(size.height) + 22;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _infoLabel = [[UILabel alloc]init];
        _infoLabel.font = [UIFont themeFontRegular:12];
        _infoLabel.textColor = [UIColor themeGray4];
        
        _infoLabel.numberOfLines = 0;
        _infoLabel.preferredMaxLayoutWidth = ([UIScreen mainScreen].bounds.size.width - 40);
        _infoLabel.text = @"*该部分内容有幸福里运营部不定期整理更新，欢迎补充，共建安全租房交易环境";
        
        [self addSubview:_infoLabel];
        
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
