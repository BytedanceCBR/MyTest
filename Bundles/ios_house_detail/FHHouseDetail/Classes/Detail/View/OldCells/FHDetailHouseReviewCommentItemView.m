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
#import "TTAccountLoginPCHHeader.h"
#import "UIViewAdditions.h"

@interface FHDetailHouseReviewCommentItemView () <TTUGCAttributedLabelDelegate>
@property(nonatomic, strong) UIControl *realtorInfoContainerView;
@property(nonatomic, strong) UIControl *realtorLabelContainer;
@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UIImageView *identifyView;
@property(nonatomic, strong) UIButton *licenceIcon;
@property(nonatomic, strong) UIView *verticalDivider;
@property(nonatomic, strong) UIButton *callBtn;
@property(nonatomic, strong) UIButton *imBtn;
@property(nonatomic, strong) UILabel *nameView;
@property(nonatomic, strong) UILabel *agencyView;
@property(nonatomic, strong) UILabel *houseReviewView;

@end

@implementation FHDetailHouseReviewCommentItemView

+ (CGFloat)heightForData:(FHDetailHouseReviewCommentModel *)data {
    if (data.commentHeight <= 0) {
        [FHDetailHouseReviewCommentItemView calculateHeight:data isExpand:data.isExpended];
    }
    return 42 + 10 + data.commentHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.clipsToBounds = YES;
    _realtorInfoContainerView = [[UIControl alloc] init];
    [self addSubview:_realtorInfoContainerView];

    _avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
    _avatarView.layer.cornerRadius = 21;
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.clipsToBounds = YES;
    [self.realtorInfoContainerView addSubview:_avatarView];

    _identifyView = [[UIImageView alloc] init];
    [self.realtorInfoContainerView addSubview:_identifyView];

    _realtorLabelContainer = [[UIControl alloc] init];
    [self.realtorInfoContainerView addSubview:_realtorLabelContainer];

    _licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateSelected];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
    [self.realtorLabelContainer addSubview:_licenceIcon];

    self.nameView = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _nameView.textColor = [UIColor themeGray1];
    _nameView.font = [UIFont themeFontMedium:14];
    _nameView.textAlignment = NSTextAlignmentLeft;
    [self.realtorLabelContainer addSubview:_nameView];

    _verticalDivider = [[UIView alloc] init];
    _verticalDivider.backgroundColor = [UIColor themeGray6];
    [self.realtorLabelContainer addSubview:_verticalDivider];

    self.agencyView = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _agencyView.textColor = [UIColor themeGray3];
    _agencyView.textAlignment = NSTextAlignmentLeft;
    [self.realtorLabelContainer addSubview:_agencyView];

    _houseReviewView = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _houseReviewView.textColor = [UIColor themeGray3];
    _houseReviewView.textAlignment = NSTextAlignmentLeft;
    [self.realtorLabelContainer addSubview:_houseReviewView];

    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateHighlighted];
    [self.realtorInfoContainerView addSubview:_callBtn];

    _imBtn = [[FHExtendHotAreaButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal"] forState:UIControlStateNormal];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateSelected];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateHighlighted];
    [self.realtorInfoContainerView addSubview:_imBtn];
    
    _commentView = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _commentView.delegate = self;
    _commentView.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    [self addSubview:_commentView];
    
    [_licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
    [_callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [_imBtn addTarget:self action:@selector(imClick:) forControlEvents:UIControlEventTouchUpInside];
    [_realtorInfoContainerView addTarget:self action:@selector(realtorInfoClick:) forControlEvents:UIControlEventTouchUpInside];
    [_realtorLabelContainer addTarget:self action:@selector(realtorInfoClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.realtorInfoContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(42);
    }];

    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.height.width.mas_equalTo(42);
        make.left.mas_equalTo(20);
    }];

    [self.identifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.avatarView).mas_offset(2);
        make.centerX.mas_equalTo(self.avatarView);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(0);
    }];

    [self.realtorLabelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarView.mas_right).offset(10);
        make.right.mas_equalTo(self.imBtn.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.avatarView);
        make.height.mas_equalTo(37);
    }];

    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.realtorLabelContainer);
        make.top.mas_equalTo(self.realtorLabelContainer);
        make.width.mas_equalTo(42);
        make.height.mas_equalTo(20);
    }];

    [self.verticalDivider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameView.mas_right).offset(6);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(14);
        make.centerY.mas_equalTo(self.nameView);
    }];

    [self.agencyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameView);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.verticalDivider.mas_right).offset(6);
        make.right.mas_lessThanOrEqualTo(self.licenceIcon.mas_left).offset(5);
    }];

    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.agencyView.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.nameView);
        make.right.mas_lessThanOrEqualTo(self.realtorLabelContainer);
    }];

    [self.houseReviewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameView.mas_bottom);
        make.left.mas_equalTo(self.realtorLabelContainer);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self.realtorLabelContainer);
    }];

    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.avatarView);
    }];

    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-20);
        make.centerY.mas_equalTo(self.avatarView);
    }];

    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(0);
        make.top.mas_equalTo(52);
    }];
}

- (void)refreshIdentifyView:(UIImageView *)identifyView withUrl:(NSString *)imageUrl
{
    if (!identifyView) {
        return;
    }
    if (imageUrl.length > 0) {
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:imageUrl] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (!error && image) {
                identifyView.image = image;
                CGFloat ratio = 0;
                if (image.size.height > 0) {
                    ratio = image.size.width / image.size.height;
                }
                [identifyView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(14 * ratio);
                }];
            }
        }];
        identifyView.hidden = NO;
    }else {
        identifyView.hidden = YES;
    }
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
        [self.avatarView bd_setImageWithURL:[NSURL URLWithString:modelData.realtorInfo.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
    }
    self.curData = modelData;
    self.nameView.text = modelData.realtorInfo.realtorName ?: @"";
    self.agencyView.text = modelData.realtorInfo.agencyName ?: @"";
    self.licenceIcon.hidden = isEmptyString(modelData.realtorInfo.businessLicense) && isEmptyString(modelData.realtorInfo.certificate);
    [self refreshIdentifyView:self.identifyView withUrl:modelData.realtorInfo.imageTag.imageUrl];

    self.commentView.height = self.curData.commentHeight;

    [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(modelData.commentHeight);
    }];
    
    [self setComment:modelData];
    self.houseReviewView.text = modelData.commentText ?: @"";
    [self.nameView mas_updateConstraints:^(MASConstraintMaker *make) {
        NSUInteger nameLen = MIN(self.nameView.text.length, 4);
        make.width.mas_equalTo(nameLen * 14 + 1);
    }];
    [self.agencyView mas_updateConstraints:^(MASConstraintMaker *make) {
        NSUInteger agencyLen = MIN(self.agencyView.text.length, 6);
        make.width.mas_equalTo(agencyLen * 14 + 1);
    }];
    [self.realtorLabelContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        NSInteger height = isEmptyString(self.houseReviewView.text) ? 20 : 37;
        make.height.mas_equalTo(height);
    }];
}

+ (void)calculateHeight:(FHDetailHouseReviewCommentModel *)modelData isExpand:(BOOL)isExpand {
    NSUInteger numberOfLines = isExpand ? 0 : 3;
    if (isExpand) {
        NSAttributedString *attributedText1 = [self stringToAttributeString:modelData.commentData
                                                                       font:[UIFont themeFontRegular:14]
                                                              numberOfLines:numberOfLines];
        NSAttributedString *attributedText2 = [self stringToAttributeString:[NSString stringWithFormat:@"%@收起", modelData.commentData]
                                                                       font:[UIFont themeFontRegular:14]
                                                              numberOfLines:numberOfLines];

        CGSize size1 = [TTTAttributedLabel sizeThatFitsAttributedString:attributedText1
                                                        withConstraints:CGSizeMake(SCREEN_WIDTH - 40, FLT_MAX)
                                                 limitedToNumberOfLines:numberOfLines];

        CGSize size2 = [TTTAttributedLabel sizeThatFitsAttributedString:attributedText2
                                                        withConstraints:CGSizeMake(SCREEN_WIDTH - 40, FLT_MAX)
                                                 limitedToNumberOfLines:numberOfLines];
        modelData.commentHeight = MAX(size1.height, size2.height);
        modelData.addFoldDirect = size1.height == size2.height;
        modelData.isExpended = isExpand;
        return;
    }
    NSAttributedString *attributedText = [self stringToAttributeString:modelData.commentData
                                                                  font:[UIFont themeFontRegular:14]
                                                         numberOfLines:numberOfLines];
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedText
                                                   withConstraints:CGSizeMake(SCREEN_WIDTH - 40, FLT_MAX)
                                            limitedToNumberOfLines:numberOfLines];
    modelData.commentHeight = size.height;
    modelData.isExpended = isExpand;
}

- (void)setComment:(FHDetailHouseReviewCommentModel *)modelData {
    if (!modelData.isExpended) {
        NSAttributedString *attributedText = [FHDetailHouseReviewCommentItemView stringToAttributeString:modelData.commentData
                                                                                                    font:[UIFont themeFontRegular:14]
                                                                                           numberOfLines:3];
        NSAttributedString *truncationToken = [FHUGCCellHelper truncationFont:[UIFont themeFontRegular:14]
                                                                 contentColor:[UIColor themeGray1]
                                                                        color:[UIColor themeRed3]];
        self.commentView.attributedTruncationToken = truncationToken;

        self.commentView.numberOfLines = 3;
        [self.commentView setText:attributedText];
        return;
    }
    NSString *content = modelData.addFoldDirect ? [NSString stringWithFormat:@"%@ 收起", modelData.commentData] : [NSString stringWithFormat:@"%@\n收起", modelData.commentData];
    NSAttributedString *attributedText = [FHDetailHouseReviewCommentItemView stringToAttributeString:content
                                                                                                font:[UIFont themeFontRegular:14]
                                                                                       numberOfLines:0];

    NSMutableAttributedString *mutableAttributedString = [attributedText mutableCopy];
    NSUInteger length = @"收起".length;
    [mutableAttributedString addAttribute:NSLinkAttributeName  // 修复点击问题的bug 强制加一个无用action
                                    value:[NSURL URLWithString:defaultTruncationLinkURLString]
                                    range:NSMakeRange(content.length - length, length)];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor themeRed3] range:NSMakeRange(content.length - length, length)];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:14] range:NSMakeRange(content.length - length, length)];

    self.commentView.linkAttributes = @{NSForegroundColorAttributeName:[UIColor themeRed3],NSFontAttributeName:[UIFont themeFontRegular:14]};
    self.commentView.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor themeRed3],NSFontAttributeName:[UIFont themeFontRegular:14]};
    self.commentView.attributedTruncationToken = nil;
    self.commentView.numberOfLines = 0;
    [self.commentView setText:[mutableAttributedString copy]];
}

#pragma mark - TTUGCAttributedLabelDelegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (label == self.commentView && [url.absoluteString isEqualToString:defaultTruncationLinkURLString]) {
        [FHDetailHouseReviewCommentItemView calculateHeight:self.curData isExpand:!self.curData.isExpended];
        if (self.delegate) {
            [self.delegate onReadMoreClick:self];
        }
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

- (void)phoneClick:(UIControl *)control {
    if (self.delegate) {
        [self.delegate onCallClick:self];
    }
}

- (void)licenseClick:(UIControl *)control {
    if (self.delegate) {
        [self.delegate onLicenseClick:self];
    }
}

- (void)imClick:(UIControl *)control {
    if (self.delegate) {
        [self.delegate onImClick:self];
    }
}

- (void)realtorInfoClick:(UIControl *)control {
    if (self.delegate) {
        [self.delegate onRealtorInfoClick:self];
    }
}
@end
