//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCPureTitleCell.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import <UIImageView+BDWebImage.h>
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText.h"
#import "TTBaseMacro.h"
#import "TTUGCEmojiParser.h"
#import "FHUGCCellHelper.h"

#define leftMargin 20
#define rightMargin 20

@interface FHUGCPureTitleCell ()

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) UIView *bottomSepView;

@end

@implementation FHUGCPureTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    
    [self.contentView addSubview:self.contentLabel];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_bottomView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(30);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(20);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 5;
//        _contentLabel.font = [UIFont themeFontRegular:16];
//        _contentLabel.textColor = [UIColor themeGray1];
//        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"升级代表同意"];
//        [string addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"]} range:NSMakeRange(0, string.length)];
//
//        NSMutableAttributedString *link = [[NSMutableAttributedString alloc] initWithString:@"“飞聊通行证用户协议”"];
//        [string appendAttributedString:link];
//        [_contentLabel setText:string];
//        _contentLabel.linkAttributes = @{NSUnderlineColorAttributeName:[UIColor clearColor],
//                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:@"3F6799"],
//                                         };
//        _contentLabel.activeLinkAttributes = @{NSUnderlineColorAttributeName:[UIColor clearColor],
//                                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"3F6799"],
//                                               };
//        _contentLabel.delegate = self;
//        _contentLabel.font = [UIFont systemFontOfSize:12.f];
//        NSString *html = @"https://api.feiliao.com/fer/protocol/authorization";
//        NSString *url = [NSString stringWithFormat:@"sslocal://webview?url=%@&hide_more=1", [html URLEncodedString]];
//
//        [_contentLabel addLinkToURL:[NSURL URLWithString:url] withRange:NSMakeRange(6, string.length - 6)];
    }
    return _contentLabel;
}

//- (TTRichSpanText *)richContent {
//    if (!_richContent) {
//        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
//        _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
//    }
//    return _richContent;
//}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedUGCContentModel class]]){
        FHFeedUGCContentModel *model = (FHFeedUGCContentModel *)data;
        
        //设置userInfo
        self.userInfoView.userName.text = model.user.name;
        self.userInfoView.descLabel.text = @"今天 14:20";
        [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:model.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];

        //设置底部
        self.bottomView.position.text = @"左家庄";
        [self.bottomView.likeBtn setTitle:model.diggCount forState:UIControlStateNormal];
        [self.bottomView.commentBtn setTitle:model.commentCount forState:UIControlStateNormal];
        
        //内容
        [FHUGCCellHelper setRichContent:self.contentLabel model:model numberOfLines:5];
    }
}

@end
