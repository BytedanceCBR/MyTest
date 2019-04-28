//
//  TTMagicSwitchTableViewCell.m
//  Article
//
//  Created by 延晋 张 on 16/5/30.
//
//

#import "TTMagicSwitchTableViewCell.h"

@interface TTMagicSwitchTableViewCell ()

@property (nonatomic, strong) UISwitch *boolSwitch;

@end

@implementation TTMagicSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.boolSwitch = [[UISwitch alloc] init];
        [_boolSwitch addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = _boolSwitch;
    }
    return self;
}

- (void)switched:(UISwitch *)boolSwitch
{
    if (self.valueChangedAction) {
        self.valueChangedAction(boolSwitch.on);
    }
}

- (BOOL)on
{
    return self.boolSwitch.on;
}

- (void)setOn:(BOOL)on
{
    self.boolSwitch.on = on;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.valueChangedAction = nil;
}

@end

