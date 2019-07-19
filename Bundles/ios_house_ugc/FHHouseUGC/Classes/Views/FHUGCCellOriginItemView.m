//
//  FHUGCCellOriginItemView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/7/19.
//

#import "FHUGCCellOriginItemView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import "TTUGCAttributedLabel.h"

@interface FHUGCCellOriginItemView ()

@property(nonatomic ,strong) UIImageView *iconView;
@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;

@end

@implementation FHUGCCellOriginItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.layer.cornerRadius = 4;
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.hidden = YES;
    [self addSubview:_iconView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = 2;
    [self addSubview:_contentLabel];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)refreshWithdata:(id)data {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"[问答]千龙网·中国首都网 北京朝阳181个老旧小区将“准物业”千龙网·中国首都网，北京大道瑞"];
    [_contentLabel setText:str];
}

//- (NSAttributedString *)getContentAttributeString:(NSString *)type content:(NSString *)content {
//    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:type];
//    
//}

@end
