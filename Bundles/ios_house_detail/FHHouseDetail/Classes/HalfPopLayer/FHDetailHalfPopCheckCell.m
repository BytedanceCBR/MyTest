//
//  FHDetailHalfPopCheckCell.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopCheckCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>

#define HOR_MARGIN 20
#define TOP_MARGIN 20
#define CONTENT_VER_MARGIN 10

@interface FHDetailHalfPopCheckCell ()

@property(nonatomic , strong) UILabel *contentLabel;
@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHDetailHalfPopCheckCell

+(CGFloat)heightForTile:(NSString *)title tip:(NSString *)tip
{
    CGFloat height = TOP_MARGIN;
    
    UIFont *font = [UIFont themeFontRegular:14];
    height += [title boundingRectWithSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width - 2*HOR_MARGIN, INT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.height;
    
    height = ceil(height) + CONTENT_VER_MARGIN + 19;
    
    return height;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont themeFontRegular:14];
        _contentLabel.textColor = [UIColor themeGray3];
        _contentLabel.preferredMaxLayoutWidth = CGRectGetWidth([[UIScreen mainScreen]bounds]) - 2*HOR_MARGIN;
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor themeGray4];
        _tipLabel.font = _contentLabel.font;
        
        [self.contentView addSubview:_contentLabel];
        [self.contentView addSubview:_tipLabel];
        
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN);
            make.right.mas_equalTo(-HOR_MARGIN);
            make.top.mas_equalTo(TOP_MARGIN);
        }];
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(HOR_MARGIN);
            make.right.mas_equalTo(-HOR_MARGIN);
            make.top.mas_equalTo( self.contentLabel.mas_bottom ).offset( CONTENT_VER_MARGIN );
            make.height.mas_equalTo(19);
            make.bottom.mas_equalTo(self.contentView).offset(-30);
        }];        
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateWithTitle:(NSString *)title tip:(NSString *)tip
{
    self.contentLabel.text = title;
    self.tipLabel.text = tip;
    
}


@end
