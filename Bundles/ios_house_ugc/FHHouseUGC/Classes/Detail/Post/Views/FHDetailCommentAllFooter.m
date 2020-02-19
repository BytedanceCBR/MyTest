//
//  FHDetailCommentAllFooter.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/12.
//

#import "FHDetailCommentAllFooter.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@implementation FHDetailCommentAllFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    _allCommentLabel = [[UILabel alloc] init];
    _allCommentLabel.text = @"全部评论";
    _allCommentLabel.textColor = [UIColor themeGray1];
    _allCommentLabel.font = [UIFont themeFontMedium:16];
    [self addSubview:_allCommentLabel];
    [_allCommentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(23);
    }];
}

@end
