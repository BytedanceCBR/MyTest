//
//  FHMessageTipView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/26.
//

#import "FHMessageTipView.h"

@interface FHMessageTipView ()

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) UILabel *unreadLabel;
@property(nonatomic, strong) UIView *unreadView;

@end

@implementation FHMessageTipView

- (instancetype)initWithCount:(NSInteger)count {
    self = [super initWithFrame:CGRectZero];
    if(self){
        _count = count;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
//    self.unreadView = [[UIView alloc] init];
//    _unreadView.backgroundColor = [UIColor whiteColor];
//    _unreadView.layer.masksToBounds = YES;
//    _unreadView.layer.cornerRadius = 8;
//    _unreadView.hidden = YES;
//    [self.contentView addSubview:_unreadView];
//    
//    self.unreadLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
//    
//    _unreadLabel.backgroundColor = [UIColor themeBRed1];
//    _unreadLabel.textAlignment = NSTextAlignmentCenter;
//    _unreadLabel.layer.masksToBounds = YES;
//    _unreadLabel.layer.cornerRadius = 7;
//    [self.unreadView addSubview:_unreadLabel];
}

- (void)initConstraints {
//    [self.unreadView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.iconView.mas_right);
//        make.top.mas_equalTo(self.iconView.mas_top);
//        make.height.mas_equalTo(16);
//        make.width.greaterThanOrEqualTo(@16);
//    }];
//
//    [self.unreadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.unreadView.mas_right).offset(-1);
//        make.left.mas_equalTo(self.unreadView.mas_left).offset(1);
//        make.top.mas_equalTo(self.unreadView.mas_top).offset(1);
//        make.bottom.mas_equalTo(self.unreadView.mas_bottom).offset(-1);
//        make.width.mas_equalTo(14);
//    }];
}

@end
