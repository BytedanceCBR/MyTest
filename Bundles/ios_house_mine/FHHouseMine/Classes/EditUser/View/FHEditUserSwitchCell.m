//
//  FHEditUserSwitchCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/15.
//

#import "FHEditUserSwitchCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTUserProfileCheckingView.h"
#import "ToastManager.h"

@interface FHEditUserSwitchCell()

@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UISwitch* switchBtn;
@property (nonatomic, assign) NSTimeInterval switchClickInterval;
@property (nonatomic, assign) NSTimeInterval startClickTime;

@end

@implementation FHEditUserSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor themeGray1];
    _nameLabel.font = [UIFont themeFontRegular:16];
    [self.contentView addSubview:_nameLabel];
    
    self.switchBtn = [[UISwitch alloc] init];
    _switchBtn.on = YES;
    [_switchBtn addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
    [self.contentView addSubview:_switchBtn];
    
}

- (void)initConstraints {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.switchBtn.mas_left).offset(-20);
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-28);
    }];
}

- (void)updateCell:(NSDictionary *)dic {
    self.nameLabel.text = dic[@"name"];
//
//    if(dic[@"isAuditing"]){
//        self.checkingView.hidden = ![dic[@"isAuditing"] boolValue];
//    }
}

- (void)valueChanged:(UISwitch *)sender {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - self.startClickTime;
    if(interval < 3){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sender setOn:!sender.isOn animated:YES];
        });
        [[ToastManager manager] showToast:@"3秒内不能重复设置"];
    }else{
        self.startClickTime = [[NSDate date] timeIntervalSince1970];
        if(self.delegate && [self.delegate respondsToSelector:@selector(changeHomePageAuth:)]){
            [self.delegate changeHomePageAuth:sender.on];
        }
    }
}

@end
