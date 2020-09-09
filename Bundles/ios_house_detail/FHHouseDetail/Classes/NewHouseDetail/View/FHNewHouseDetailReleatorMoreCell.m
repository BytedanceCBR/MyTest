//
//  FHNewHouseDetailReleatorMoreCell.m
//  Pods
//
//  Created by bytedance on 2020/9/9.
//

#import "FHNewHouseDetailReleatorMoreCell.h"
#import <ByteDanceKit/ByteDanceKit.h>

@implementation FHNewHouseDetailReleatorMoreCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) weakSelf = self;
        self.foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部" upText:@"收起" isFold:YES];
        self.foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
        self.foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
        self.foldButton.keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
         self.foldButton.keyLabel.font = [UIFont themeFontRegular:14];
        [self.foldButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.foldButtonActionBlock) {
                weakSelf.foldButtonActionBlock();
            }
        }];
        [self.contentView addSubview:self.foldButton];
        [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.left.right.mas_equalTo(0);
        }];
    }
    return self;
}

@end
