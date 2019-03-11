//
//  TTCommentReplyTableViewCell.m
//  Article
//
//  Created by 冯靖君 on 15/12/3.
//
//

#import "TTCommentReplyTableViewCell.h"
#import "TTCommentTextAttachment.h"
#import "TTCommentImageHelper.h"
#import <TTPlatformBaseLib/TTIconFontDefine.h>
#import <TTUIWidget/UILabel+Tapping.h>
#import <TTVerifyKit/TTVerifyIconTextAttachment.h>
#import <TTBaseLib/TTLabelTextHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTBaseLib/NSString-Extension.h>
#import <TTUGCFoundation/TTRichSpanText+Emoji.h>
#import <TTRoute/TTRoute.h>
#import <TTThemed/TTThemeManager.h>


#define kTTCommentContentLabelQuotedCommentUserURLString @"com.bytedance.kTTCommentContentLabelQuotedCommentUserURLString"

@interface TTCommentReplyTableViewCell () <TTLabelTappingDelegate>

@property(nonatomic, strong) SSThemedLabel *replyLabel;
@property(nonatomic, strong) TTCommentReplyModel *replyModel;
@property(nonatomic, copy) TTCommentReplyActionBlock userActionBlock;
@property(nonatomic, assign) NSRange userNameRange;
@property(nonatomic, assign) NSRange verifyIconRange;
@property(nonatomic, assign) NSRange userRoleIconRange;

@end

@implementation TTCommentReplyTableViewCell

- (void)dealloc
{
    _replyLabel.labelTappingDelegate = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)prepareForReuse
{
    [_replyLabel removeFromSuperview];
    _replyLabel = nil;
}

- (void)buildReplyLabelIfNeeded
{
    if (!_replyLabel) {
        _replyLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kHMargin, kVMargin / 2, 0, 0)];
        _replyLabel.needSimultaneouslyScrollGesture = YES;
        _replyLabel.textAlignment = NSTextAlignmentLeft;
        _replyLabel.backgroundColor = [UIColor clearColor];
        _replyLabel.numberOfLines = kMaxlineNumber;
        _replyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _replyLabel.labelTappingDelegate = self;
        [self.contentView addSubview:_replyLabel];
    }
}

- (void)refreshWithModel:(TTCommentReplyModel *)replyModel width:(CGFloat)width
{
    [self buildReplyLabelIfNeeded];

    _replyModel = replyModel;
    NSString *content = [NSString stringWithFormat:@"%@ ", replyModel.replyUserName];
    NSMutableAttributedString *attrString = [TTLabelTextHelper attributedStringWithString:content
                                                                                 fontSize:[self.class tt_fontSize]
                                                                               lineHeight:[self.class tt_lineHeight]
                                                                            lineBreakMode:NSLineBreakByTruncatingTail];
    self.userNameRange = NSMakeRange(0, replyModel.replyUserName.length);
    self.verifyIconRange = NSMakeRange(NSNotFound, 0);
    //去认证V
//    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:replyModel.userAuthInfo]) {
//        TTVerifyIconTextAttachment *textAttachment = [TTVerifyIconTextAttachment textAttachmentWithVerifyInfo:replyModel.userAuthInfo bounds:CGRectMake(0, 0, 0, [self.class tt_vSize])];
//        NSAttributedString *verifyAttrString = [NSAttributedString attributedStringWithAttachment:textAttachment];
//        self.verifyIconRange = NSMakeRange(attrString.length, verifyAttrString.length);
//        [attrString appendAttributedString:verifyAttrString];
//    }

    NSUInteger userRoleIndex = attrString.length;

    if (!isEmptyString(replyModel.replyContent)) {
        NSString *replyContent = [NSString stringWithFormat:@": %@", replyModel.replyContent];
        NSMutableAttributedString *replyAttrString = [[TTUGCEmojiParser parseInTextKitContext:replyContent fontSize:[self.class tt_fontSize]] mutableCopy];
        NSDictionary *attributes = [NSString tt_attributesWithFont:[UIFont systemFontOfSize:[self.class tt_fontSize]]
                                                        lineHeight:[self.class tt_lineHeight]
                                                     lineBreakMode:NSLineBreakByWordWrapping
                                                   firstLineIndent:0
                                                         alignment:NSTextAlignmentLeft];
        [replyAttrString addAttributes:attributes range:NSMakeRange(0, replyAttrString.length)];

        [attrString appendAttributedString:replyAttrString];
    }

    self.userRoleIconRange = NSMakeRange(NSNotFound, 0);
    __block BOOL hasRefreshed = NO; //标记量，表示已刷新attributeText
    if (replyModel.authorBadge.count) {
        NSMutableAttributedString *userRoleAttrString = [[NSMutableAttributedString alloc] init];
        NSMutableArray<TTImageInfosModel *> *infoModels = [NSMutableArray array];
        for (NSDictionary *dict in replyModel.authorBadge) {
            TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
            if (model) {
                [infoModels addObject:model];
            }
        }

        [infoModels enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTCommentTextAttachment *tempAttachment = [[TTCommentTextAttachment alloc] init];
            [tempAttachment setupBoundsWithImageSize:CGSizeMake(obj.width, obj.height)
                                         labelHeight:[[self class] tt_fontSize] - 1];
            [TTCommentImageHelper setupObjectImageWithInfoModel:obj object:nil callback:^(UIImage * _Nullable image) {
                BOOL isDayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
                tempAttachment.image = isDayMode ? image : [TTCommentImageHelper nightImageWithOriginImage:image];
                NSAttributedString *spaceAttr = [[NSAttributedString alloc] initWithString:@" " attributes:@{
                    NSFontAttributeName: [UIFont systemFontOfSize:6]
                }];
                [userRoleAttrString appendAttributedString:spaceAttr];
                [userRoleAttrString appendAttributedString:[NSAttributedString attributedStringWithAttachment:tempAttachment]];

                if (idx == infoModels.count - 1) { // 所有UIImage回调完成，构造attributeString
                    self.userRoleIconRange = NSMakeRange(userRoleIndex, userRoleAttrString.length);
                    [attrString insertAttributedString:userRoleAttrString atIndex:userRoleIndex];
                    if (hasRefreshed) { //SD的imageCache如果已下载会同步回调（此处不刷新），如果是未下载则异步回调，需要再重新刷新一次attributeText
                        [self refreshReplyLabelWithAttributedText:attrString];
                    }
                }
            }];
        }];
    }

    hasRefreshed = YES;
    [self refreshReplyLabelWithAttributedText:attrString];
    CGFloat labelWidth = width - kHMargin*2;
    CGFloat labelHeight = [self.class heightForReplyModel:replyModel width:labelWidth];
    _replyLabel.size = CGSizeMake(labelWidth, labelHeight);
}

- (void)handleUserClickActionWithBlock:(TTCommentReplyActionBlock)block
{
    if (block) {
        self.userActionBlock = block;
    }
}

- (void)refreshReplyLabelWithAttributedText:(NSAttributedString *)attributedText
{
    NSString *content = [attributedText string];
    NSRange replyRange = NSMakeRange(NSNotFound, 0);
    NSMutableAttributedString *mAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    if (!isEmptyString(_replyModel.replyContent)) {
        NSString *replyContent = [NSString stringWithFormat:@": %@", _replyModel.replyContent];
        NSAttributedString *replyAttrString = [TTUGCEmojiParser parseInTextKitContext:replyContent fontSize:[self.class tt_fontSize]];
        replyRange = [content rangeOfString:replyAttrString.string];
        [mAttributedText addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kFHColorCharcoalGrey) range:replyRange];
    }
    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:_replyModel.userAuthInfo]) {
        if (self.verifyIconRange.location != NSNotFound) {
            TTVerifyIconTextAttachment *textAttachment = [TTVerifyIconTextAttachment textAttachmentWithVerifyInfo:_replyModel.userAuthInfo bounds:CGRectMake(0, 0, 0, [self.class tt_vSize])];
            NSAttributedString *verifyAttrString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            if (NSMaxRange(self.verifyIconRange) <= mAttributedText.length) {
                [mAttributedText replaceCharactersInRange:self.verifyIconRange withAttributedString:verifyAttrString];
            }
        }
    }
    if (_replyModel.authorBadge.count) {
        if (self.userRoleIconRange.location != NSNotFound) {
            // enumerate如果调用在MutableAttributedString上，允许直接mutate对象，不需要重建
            [mAttributedText enumerateAttribute:NSAttachmentAttributeName inRange:self.userRoleIconRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                if (value && [value isKindOfClass:[NSTextAttachment class]]) {
                    NSTextAttachment *tempAttachment = (NSTextAttachment *)value;
                    UIImage *image = tempAttachment.image;
                    BOOL isDayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
                    tempAttachment.image = isDayMode ? [TTCommentImageHelper dayImageWithOriginImage:image] : [TTCommentImageHelper nightImageWithOriginImage:image];
                }
            }];
        }
    }

    NSDictionary *inactiveLinkAttributes = @{NSForegroundColorAttributeName:self.replyModel.notReplyMsg ? SSGetThemedColorWithKey(kFHColorRed3) : SSGetThemedColorWithKey(kFHColorCoolGrey3) };
    NSDictionary *activeLinkAttributes = @{NSForegroundColorAttributeName:SSGetThemedColorWithKey(kFHColorRed3)};
    _replyLabel.labelInactiveLinkAttributes = inactiveLinkAttributes;
    _replyLabel.labelActiveLinkAttributes = activeLinkAttributes;
    _replyLabel.attributedText = mAttributedText;
    [_replyLabel removeAllLinkAttributes];

    if (self.userNameRange.location != NSNotFound) {
        [_replyLabel addLinkToLabelWithURL:[NSURL URLWithString:kTTCommentContentLabelQuotedCommentUserURLString] range:self.userNameRange];
    }

    if (_replyModel.replyContentRichSpanJSONString) {
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:_replyModel.replyContent
                                                        richSpansJSONString:_replyModel.replyContentRichSpanJSONString];

        NSArray <TTRichSpanLink *> *richSpanLinks = [richSpanText richSpanLinksOfAttributedString];
        for (TTRichSpanLink *link in richSpanLinks) {
            NSRange linkRange = NSMakeRange(replyRange.location + 2 + link.start, link.length); // replyContent 字段是 ": XXX" 格式

            if (NSMaxRange(linkRange) <= content.length) {
                [_replyLabel addLinkToLabelWithURL:[NSURL URLWithString:link.link] range:linkRange];
            }
        }
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [self refreshReplyLabelWithAttributedText:_replyLabel.attributedText];
}

+ (CGFloat)heightForReplyModel:(TTCommentReplyModel *)replyModel width:(CGFloat)width
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    UIFont *font = [UIFont systemFontOfSize:[self tt_fontSize]];
    CGFloat lineHeightMultiple = [self tt_lineHeight] / font.lineHeight;
    CGFloat constraintHeight = kMaxlineNumber * ([self tt_lineHeight] + 1);

    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    style.lineHeightMultiple = lineHeightMultiple;
    style.minimumLineHeight = font.lineHeight * lineHeightMultiple;
    style.maximumLineHeight = font.lineHeight * lineHeightMultiple;
    style.firstLineHeadIndent = 0;

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:replyModel.replyUserName];

    if (replyModel.isArticleAuthor) {
        NSAttributedString *authorAttrString = [[NSAttributedString alloc] initWithString:@" "iconfont_author];
        [attrString appendAttributedString:authorAttrString];
    }
    NSString *userAuthInfo = replyModel.userAuthInfo;
    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userAuthInfo]) {
        TTVerifyIconTextAttachment *textAttachment = [TTVerifyIconTextAttachment textAttachmentWithVerifyInfo:userAuthInfo bounds:CGRectMake(0, 0, 0, [self.class tt_vSize])];
        NSAttributedString *verifyAttrString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attrString appendAttributedString:verifyAttrString];
    }
    if (replyModel.authorBadge.count) {
        NSMutableAttributedString *userRoleAttrString = [[NSMutableAttributedString alloc] init];
        NSMutableArray<TTImageInfosModel *> *infoModels = [NSMutableArray array];
        for (NSDictionary *dict in replyModel.authorBadge){
            TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
            if (model) {
                [infoModels addObject:model];
            }
        }
        [infoModels enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTCommentTextAttachment *tempTextAttachment = [[TTCommentTextAttachment alloc] init];
            [tempTextAttachment setupBoundsWithImageSize:CGSizeMake(obj.width, obj.height)
                                             labelHeight:[[self class] tt_fontSize] - 1];
            [userRoleAttrString appendAttributedString:[NSAttributedString attributedStringWithAttachment:tempTextAttachment]];
        }];
        [attrString appendAttributedString:userRoleAttrString];
    }
    if (!isEmptyString(replyModel.replyContent)) {
        NSAttributedString *replayContentAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@", replyModel.replyContent]];
        [attrString appendAttributedString:replayContentAttrString];
    }
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(width, ceil(constraintHeight)) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    CGFloat height = fmin(ceil(constraintHeight),ceil(size.height));

    return height;
}

+ (CGFloat)tt_fontSize
{
    return [self fitSizeWithiPhone6:15.f iPhone5:14.f];
}

+ (CGFloat)tt_vSize
{
    return ceil(14 * [self tt_fontSize] / 15);
}

+ (CGFloat)tt_lineHeight
{
    return [TTDeviceUIUtils tt_newPadding:20.f];
}

+ (CGFloat)fitSizeWithiPhone6:(CGFloat)size6 iPhone5:(CGFloat)size5 {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
            return size6 * 1.3;
        case TTDeviceMode736:
        case TTDeviceMode667:
            return size6;
        case TTDeviceMode568:
        case TTDeviceMode480:
            return size5;
        default:
            return size6;
    }
}

#pragma mark - TTLabelTapping Delegate

- (void)label:(UILabel *)label didSelectLinkWithURL:(NSURL *)URL
{
    if ([URL.absoluteString isEqualToString:kTTCommentContentLabelQuotedCommentUserURLString]) {
        if (self.userActionBlock) {
            self.userActionBlock(self.replyModel);
        }
    } else {
        if ([[TTRoute sharedRoute] canOpenURL:URL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:URL];
        }
    }
}

@end
