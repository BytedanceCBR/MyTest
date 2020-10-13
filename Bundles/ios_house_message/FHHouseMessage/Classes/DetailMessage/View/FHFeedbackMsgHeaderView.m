//
//  FHFeedbackMsgHeaderView.m
//  FHHouseMessage
//
//  Created by bytedance on 2020/10/13.
//

#import "FHFeedbackMsgHeaderView.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"

@implementation FHFeedbackMsgHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.dateView = [[UIView alloc] init];
    self.dateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    self.dateView.layer.cornerRadius = 4;
    self.dateView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.dateView];
    [self.dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self);
    }];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont themeFontRegular:12];
    self.dateLabel.textColor = [UIColor whiteColor];
    [_dateView addSubview:_dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateView.mas_left).offset(10);
        make.right.mas_equalTo(self.dateView.mas_right).offset(-10);
        make.center.mas_equalTo(self.dateView);
    }];
}

@end
