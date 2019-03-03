//
//  FHHouseFindHeaderView.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindHeaderView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

@interface FHHouseFindHeaderView ()

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIButton *deleteButton;

@end

@implementation FHHouseFindHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeBlue1];
        
        [self addSubview:_titleLabel];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton addTarget:self
                          action:@selector(deleteAction)
                forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.bottom.mas_equalTo(self).offset(-14);
            make.right.mas_lessThanOrEqualTo(self.deleteButton.mas_left).offset(-10);
        }];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_equalTo(self).offset(-10);
        }];
        
    }
    return self;
}

-(void)updateTitle:(NSString *)title showDelete:(BOOL)showDelete
{
    self.titleLabel.text = title;
    self.deleteButton.hidden = !showDelete;
}

-(void)deleteAction
{
    if (_deleteBlock) {
        _deleteBlock(self);
    }
}

@end
