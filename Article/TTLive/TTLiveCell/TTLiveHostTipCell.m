//
//  TTLiveHostTipCell.m
//  Article
//
//  Created by chenjiesheng on 2017/6/9.
//
//

#import "TTLiveHostTipCell.h"
#import "TTLiveMessage.h"
#import "TTLiveCellHelper.h"

#import <SSThemed.h>
#import <TTAsyncLabel.h>
#import <TTRoute.h>
@interface TTLiveHostTipCell ()

@property (nonatomic, strong)TTAsyncLabel *tipLabel;
@property (nonatomic, strong)TTLiveMessage *tipMessage;
@end

@implementation TTLiveHostTipCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setupSubViews];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setupSubViews{
    _tipLabel = [[TTAsyncLabel alloc] init];
    _tipLabel.font = [UIFont systemFontOfSize:TTLiveFontSize(14)];
    _tipLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    _tipLabel.linkColor = [UIColor tt_themedColorForKey:kColorText5];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
    WeakSelf;
    _tipLabel.prefixAction = ^{
        StrongSelf;
        if (self.tipMessage.openURLStr){
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.tipMessage.openURLStr]];
        }
    };
    [self.contentView addSubview:_tipLabel];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_tipLabel sizeToFit];
    _tipLabel.frame = CGRectMake((self.width - _tipLabel.width) /2, TTLivePadding(20), _tipLabel.width, TTLivePadding(20));
}

- (void)setupViewWithHost:(TTLiveMessage *)tipMessage{
    _tipMessage = tipMessage;
    NSString *text = [NSString stringWithFormat:@"%@ %@ 正在直播",tipMessage.userRoleName,tipMessage.userDisplayName];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TTLiveFontSize(14)]}];
    NSRange linkRange = [text rangeOfString:tipMessage.userDisplayName];
    _tipLabel.text = text;
    _tipLabel.linkRange = linkRange;
    _tipLabel.linkAttributed = [[NSAttributedString alloc] initWithString:tipMessage.userDisplayName attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:TTLiveFontSize(14)]}];
    _tipLabel.size = textSize;
}

@end
