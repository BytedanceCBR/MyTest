//
// Created by zhulijun on 2019-08-27.
//

#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHDetailHouseReviewCommentItemView.h"
#import "FHExtendHotAreaButton.h"
#import "MASConstraintMaker.h"
#import "UILabel+House.h"
#import "FHDetailOldModel.h"
#import "BDWebImage.h"
#import <Masonry.h>
#import "TTTAttributedLabel.h"
#import "FHUGCCellHelper.h"
#import "PNColor.h"
#import "TTUGCAttributedLabel.h"

@interface FHDetailHouseReviewCommentItemView ()<TTUGCAttributedLabelDelegate>
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UIImageView *identifyView;
@property(nonatomic, strong) UIButton *licenceIcon;
@property(nonatomic, strong) UIButton *callBtn;
@property(nonatomic, strong) UIButton *imBtn;
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *agency;

@end

@implementation FHDetailHouseReviewCommentItemView

+(CGFloat)heightForData:(FHDetailHouseReviewCommentModel *)data{
    if(data.commentHeight <= 0){
        [FHDetailHouseReviewCommentItemView calculateHeight:data isExpand:data.isExpended];
    }
    return 42 + 13 + data.commentHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
    _avatar.layer.cornerRadius = 21;
    _avatar.contentMode = UIViewContentModeScaleAspectFill;
    _avatar.clipsToBounds = YES;
    [self addSubview:_avatar];

    [self addSubview:self.identifyView];

    _licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    [self addSubview:_licenceIcon];

    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateHighlighted];
    [self addSubview:_callBtn];

    _imBtn = [[FHExtendHotAreaButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal"] forState:UIControlStateNormal];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateSelected];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateHighlighted];
    [self addSubview:_imBtn];

    self.name = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _name.textColor = [UIColor themeGray1];
    _name.font = [UIFont themeFontMedium:16];
    _name.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_name];

    self.agency = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _agency.textColor = [UIColor themeGray3];
    _agency.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_agency];

    _commentView = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _commentView.delegate = self;
    [self addSubview:_commentView];

    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.height.width.mas_equalTo(42);
        make.left.mas_equalTo(20);
    }];

    [self.identifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.avatar).mas_offset(2);
        make.centerX.mas_equalTo(self.avatar);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(38);
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(10);
        make.top.mas_equalTo(self.avatar).offset(3);
        make.height.mas_equalTo(20);
    }];

    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.name.mas_right).offset(13);
        make.right.mas_lessThanOrEqualTo(self.licenceIcon.mas_left).offset(5);
    }];

    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.agency.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];

    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.avatar);
    }];

    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-20);
        make.centerY.mas_equalTo(self.avatar);
    }];

    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(20);
       make.right.mas_equalTo(-20);
       make.height.mas_equalTo(0);
       make.top.mas_equalTo(self.avatar.mas_bottom).offset(13);
    }];
}

- (void)refreshWithData:(NSObject *)data {
    if (self.curData == data || ![data isKindOfClass:[FHDetailHouseReviewCommentModel class]]) {
        return;
    }
    FHDetailHouseReviewCommentModel *modelData = (FHDetailHouseReviewCommentModel *) data;
    if (!modelData.realtorInfo) {
        return;
    }
    if (modelData.realtorInfo.avatarUrl.length > 0) {
        [self.avatar bd_setImageWithURL:[NSURL URLWithString:modelData.realtorInfo.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
    }
    self.curData = modelData;
    self.name.text = modelData.realtorInfo.realtorName ?: @"";
    self.agency.text = modelData.realtorInfo.agencyName ?: @"";
    self.licenceIcon.hidden = isEmptyString(modelData.realtorInfo.businessLicense) && isEmptyString(modelData.realtorInfo.certificate);
    if (modelData.realtorInfo.imageTag.imageUrl.length > 0) {
        self.identifyView.hidden = NO;
        [self.identifyView bd_setImageWithURL:[NSURL URLWithString:modelData.realtorInfo.imageTag.imageUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
    } else {
        self.identifyView.hidden = YES;
    }
    [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.curData.commentHeight);
    }];
    [self setComment:modelData isExpand:modelData.isExpended];

}

+(void)calculateHeight:(FHDetailHouseReviewCommentModel *)modelData isExpand:(BOOL)isExpand{
    NSUInteger numberOfLines = isExpand ? 0 : 3;
    NSAttributedString *attributedText = [self stringToAttributeString:modelData.commentText
                                                                  font:[UIFont themeFontRegular:14]
                                                         numberOfLines:numberOfLines];
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedText
                                                   withConstraints:CGSizeMake(SCREEN_WIDTH - 40, FLT_MAX)
                                            limitedToNumberOfLines:numberOfLines];
    modelData.commentHeight = size.height;
    modelData.isExpended = isExpand;
}

-(void)setComment:(FHDetailHouseReviewCommentModel *)modelData isExpand:(BOOL)isExpand{
    NSUInteger numberOfLines = isExpand ? 0 : 3;
    NSAttributedString *attributedText = [FHDetailHouseReviewCommentItemView stringToAttributeString:modelData.commentText
                                                                  font:[UIFont themeFontRegular:14]
                                                         numberOfLines:numberOfLines];
    self.commentView.numberOfLines = numberOfLines;
    [self.commentView setText:attributedText];
    NSAttributedString* truncationToken = isExpand ? nil : [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:14]
                                                                        contentColor:[UIColor themeGray1]
                                                                               color:[UIColor themeRed3]];
    self.commentView.attributedTruncationToken = truncationToken;
}

#pragma mark - TTUGCAttributedLabelDelegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (label == self.commentView && [url.absoluteString isEqualToString:defaultTruncationLinkURLString]) {
        [FHDetailHouseReviewCommentItemView calculateHeight:self.curData isExpand:YES];
        if (self.delegate) {
            [self.delegate onReadMoreClick:self];
        }
        [self setComment:self.curData isExpand:YES];
    }
}

+ (NSAttributedString *)stringToAttributeString:(NSString *)content font:(UIFont *)font numberOfLines:(NSInteger)numberOfLines {
    TTRichSpanText *richContent = [[TTRichSpanText alloc] initWithText:content richSpans:nil];

    TTRichSpanText *threadContent = [[TTRichSpanText alloc] initWithText:@"" richSpanLinks:nil imageInfoModelDictionary:nil];

    if (!isEmptyString(content)) {
        [threadContent appendRichSpanText:richContent];
    }

    if (!isEmptyString(threadContent.text)) {
        NSInteger parseEmojiCount = -1;
        if (numberOfLines > 0) {
            parseEmojiCount = (100 * (numberOfLines + 1));// 只需解析这么多，其他解析无用~~
        }
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:threadContent.text fontSize:font.pointSize needParseCount:parseEmojiCount];
        if (attrStr) {
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:font forKey:NSFontAttributeName];

            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 2;
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];

            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];
            return [mutableAttributedString copy];
        }
    }
    return nil;
}

- (UIImageView *)identifyView {
    if (!_identifyView) {
        _identifyView = [[UIImageView alloc] init];
        [self addSubview:_identifyView];
    }
    return _identifyView;
}
@end
