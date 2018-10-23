//
//  TTVVideoDetailNatantInfoViewModel.m
//  Article
//
//  Created by lishuangyang on 2017/5/11.
//
//

#import "TTVVideoDetailNatantInfoViewModel.h"
#import "TTLabelTextHelper.h"
#import "SSThemed.h"
#import <CoreText/CoreText.h>
#import "TTVideoRecommendModel.h"
#import "TTMessageCenter.h"
#import "TTVideoArticleService+Action.h"
#import "TTVideoArticleServiceMessage.h"
#import "TTVFeedUserOpDataSyncMessage.h"

#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"
#import "TTVideoFontSizeManager.h"
#import "TTRoute.h"
#import "SSWebViewController.h"
#define VideoWatchCountKey              @"video_watch_count"

extern float tt_ssusersettingsManager_detailVideoContentFontSize();

inline CGFloat kVideoTitleFontSize() {
   return [TTVideoFontSizeManager settedTitleFontSize];
}

inline CGFloat kVideoTitleLineHeight() {
    return ceil([TTVideoFontSizeManager settedTitleFontSize] + 4);
}

@interface TTVVideoDetailNatantInfoViewModel ()

@property (nonatomic, strong)NSString *abstactHTMlString;
@property (nonatomic, strong)TTRichSpanText *richTitle;

@end

@implementation TTVVideoDetailNatantInfoViewModel

-(instancetype)initWithInfoModel:(id<TTVVideoDetailNatantInfoModelProtocol>) model;
{
    self = [super init];
    if (self) {
        self.infoModel = model;
        [self constructLabelStrings];
        [self updateAttributeTitle];
        [self updateButtonTitle];
        }
    return self;
}

-(void) constructLabelStrings{
    //title
    self.title = self.infoModel.title;
    //watchCount
    NSString *watchCountText = [TTBusinessManager formatCommentCount:[[self.infoModel.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
    NSString *originText = ![TTDeviceHelper isPadDevice] && self.infoModel.isOriginal.boolValue ? @"原创 | " : @"";
    NSInteger videoType = 0;
    if ([[self.infoModel.videoDetailInfo allKeys] containsObject:@"video_type"]) {
        videoType = ((NSNumber *)[self.infoModel.videoDetailInfo objectForKey:@"video_type"]).integerValue;
    }
    if (videoType == 1) {
        self.watchCountStr = [NSString stringWithFormat:@"累计%@人观看",watchCountText];
    }else{
        self.watchCountStr = [NSString stringWithFormat:@"%@%@次播放", originText, watchCountText];
    }
    //ContentHTMLString
    double time = self.infoModel.articlePublishTime;
    NSString *publishTime = [NSString stringWithFormat:@"%@发布", [TTBusinessManager wordDateStringSince:time]];
    NSString *content = self.infoModel.content;
    if (isEmptyString(content)) {
        content = @"";
    } else {
        content = [NSString stringWithFormat:@"%@\n", content];
    }
    NSString *videoAbstract = self.infoModel.abstract;
    if (isEmptyString(videoAbstract)) {
        videoAbstract = @"";
    }
    self.abstactHTMlString = [NSString stringWithFormat:@"%@%@",content,videoAbstract];
    NSString *abstract = nil;
    if (isEmptyString(self.abstactHTMlString)) {
        abstract = publishTime;
    } else {
        abstract = [NSString stringWithFormat:@"%@ <br/> %@", publishTime, self.abstactHTMlString];
    }
    [self updateContentLabelWithHTMLString:abstract];
    
}

- (void)updateContentLabelWithHTMLString:(NSString *)htmlString
{
    if (isEmptyString(htmlString)) {
        return;
    }
    
    NSString *reg = @"<div\\ class=\"custom-video\"[\\s\\S]*?</div>"; //去掉html中自定义的div块，尝试修复html->attributedString的卡runloop的问题
    NSRange regRange = [htmlString rangeOfString:reg options:NSRegularExpressionSearch];
    if (NSNotFound != regRange.location) {
        htmlString = [htmlString stringByReplacingCharactersInRange:regRange withString:@""];
    }
    
    @weakify(self);
    dispatch_block_t block = ^{
        @strongify(self);
        if (!self) {
            return ;
        }
        NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
        wrapperTrackEvent(@"video_parse_abstract", @"begin");
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithData:data
                                                                                          options:@{
                                                                                                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                    NSCharacterEncodingDocumentAttribute :
                                                                                                        @(NSUTF8StringEncoding)
                                                                                                    }
                                                                               documentAttributes:nil
                                                                                            error:nil];
        wrapperTrackEvent(@"video_parse_abstract", @"end");
        
        NSRange range = [attributeStr.string  rangeOfString:@"(\\n){2,}" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            [attributeStr.mutableString replaceCharactersInRange:range withString:@"\n"];
            
            range = [attributeStr.string  rangeOfString:@"(\\n){2,}" options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [attributeStr.mutableString replaceCharactersInRange:range withString:@"\n"];
            }
        }
        
        range = NSMakeRange(0, attributeStr.string.length);
        [attributeStr addAttributes:[self contentLabelTextAttributs] range:range];
        
        self.attributeString = attributeStr;
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

- (TTRichSpanText *)richTitle {
    if (!_richTitle) {
        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.infoModel.titleRichSpan];
        _richTitle = [[TTRichSpanText alloc] initWithText:self.title richSpans:richSpans];
    }
    return _richTitle;
}


- (void)updateAttributeTitle{
    TTRichSpanText *titleRichSpanText = [self.richTitle replaceWhitelistLinks];
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:titleRichSpanText.text fontSize:kVideoTitleFontSize()];
    if (!attrStr) {
        return;
    }
    
    NSDictionary *attrDic = [self.class titleLabelAttributedDictionary];
    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attrDic range:NSMakeRange(0, attrStr.length)];
    self.titleLabelAttributedStr = [mutableAttributedString copy];

    NSArray <TTRichSpanLink *> *richSpanLinks = [titleRichSpanText richSpanLinksOfAttributedString];
    if (richSpanLinks) {
        NSMutableArray *links = [NSMutableArray arrayWithCapacity:richSpanLinks.count];
        for (TTRichSpanLink *current in richSpanLinks) {
            NSRange linkRange = NSMakeRange(current.start, current.length);
            if (linkRange.location + linkRange.length <= attrStr.length) {
                UIColor *linkColor = [UIColor tt_themedColorForKey:kColorText5];
                UIColor *activeLinkColor = [UIColor tt_themedColorForKey:kColorText5];
                NSTextCheckingResult *checkingResult = [NSTextCheckingResult transitInformationCheckingResultWithRange:linkRange components:@{}];
                TTUGCAttributedLabelLink *link =
                [[TTUGCAttributedLabelLink alloc] initWithAttributes:linkColor ? @{NSForegroundColorAttributeName : linkColor} : nil
                                                       activeAttributes:activeLinkColor ? @{NSForegroundColorAttributeName : activeLinkColor} : nil
                                                     inactiveAttributes:nil
                                                     textCheckingResult:checkingResult];
                link.linkURL = [NSURL URLWithString:current.link];
                [links addObject:link];
            }
        }
        self.titleLabelLinks = links;
    }
}

+ (NSDictionary *)titleLabelAttributedDictionary{
    NSMutableDictionary * attributeDictionary = @{}.mutableCopy;
    [attributeDictionary setValue:[UIFont boldSystemFontOfSize:kVideoTitleFontSize()] forKey:NSFontAttributeName];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if ([TTDeviceHelper OSVersionNumber] < 9) {
        paragraphStyle.minimumLineHeight = kVideoTitleLineHeight();
        paragraphStyle.maximumLineHeight = kVideoTitleLineHeight();
        paragraphStyle.lineHeightMultiple = kVideoTitleLineHeight() - kVideoTitleFontSize();
    }else {
        paragraphStyle.minimumLineHeight = kVideoTitleLineHeight();
        paragraphStyle.maximumLineHeight = kVideoTitleLineHeight();
        paragraphStyle.lineSpacing = 0;
    }
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    [attributeDictionary setValue:[UIColor tt_themedColorForKey:kColorText1] forKey:NSForegroundColorAttributeName];
    return attributeDictionary.copy;
}

//定位和互动信息

- (void)updateButtonTitle{
    //ding
    int digCount = [self.infoModel.digCount intValue];
    if ([self.infoModel.userDiged boolValue] &&!digCount) {
        digCount = 1;
    }
    NSString * diggTitle = digCount > 0 ? [TTBusinessManager formatCommentCount:digCount] : NSLocalizedString(@"顶", nil);
    if (digCount < 10) {
        diggTitle = [diggTitle stringByAppendingString:@" "];
    }
    self.digTitle = diggTitle;
    //cai
    int buryCount = [self.infoModel.buryCount intValue];
    if ([self.infoModel.userBuried boolValue] &&!buryCount) {
        buryCount = 1;
    }
    NSString * buryTitle = buryCount > 0 ? [TTBusinessManager formatCommentCount:buryCount] : NSLocalizedString(@"踩", nil);
    if (buryCount < 10) {
        buryTitle = [buryTitle stringByAppendingString:@" "];
    }
    self.buryTitle = buryTitle;
}

- (void)logShowRecommentView:(NSArray *)models
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:self.infoModel.itemId forKey:@"ext_value"];
    NSMutableArray *mediaIds = [NSMutableArray array];
    for (TTVideoRecommendModel *model in models) {
        [mediaIds addObject:model.mediaID];
    }
    NSString *mediaIdsStr = [mediaIds componentsJoinedByString:@","];
    [extra setValue:mediaIdsStr forKey:@"media_ids"];
    wrapperTrackEventWithCustomKeys(@"video", @"show_zz_comment", self.uniqueID, nil, extra);
}

#pragma mark - dig/bury Action

//逻辑同TTVdiggAction
- (void)digAction{
    
    int count = [self.infoModel.digCount intValue];
    count ++;
    self.infoModel.userDiged = [NSNumber numberWithBool:YES];
    
    self.infoModel.digCount = [NSString stringWithFormat:@"%d",count];
    [self updateButtonTitle];
     TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
     
     TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
     parameter.aggr_type = self.infoModel.aggrType;
     parameter.item_id = self.infoModel.itemId;
     parameter.group_id = self.infoModel.groupId;
     parameter.ad_id = self.infoModel.adId;
     NSString *unique_id = self.infoModel.groupId ? self.infoModel.groupId : self.infoModel.adId;
     [service digg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
         SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:YES uniqueIDStr:unique_id);
         SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:count uniqueIDStr:unique_id);
     }];
    
    //可能显示appStore评分视图
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"like"}];
}

- (void)cancelDiggAction{
    int count = [self.infoModel.digCount intValue];
        count--;
    self.infoModel.userDiged = [NSNumber numberWithBool:NO];
    self.infoModel.digCount = [NSString stringWithFormat:@"%d",count];
    [self updateButtonTitle];
    TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
    
    TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
    parameter.aggr_type = self.infoModel.aggrType;
    parameter.item_id = self.infoModel.itemId;
    parameter.group_id = self.infoModel.groupId;
    parameter.ad_id = self.infoModel.adId;
    NSString *unique_id = self.infoModel.groupId ? self.infoModel.groupId : self.infoModel.adId;
    [service cancelDigg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
        SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:NO uniqueIDStr:unique_id);
        SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:count uniqueIDStr:unique_id);
    }];
}

//逻辑同TTVburyAction
- (void)buryAction{
    
    int count = [self.infoModel.buryCount intValue];
    count ++;
    self.infoModel.userBuried = [NSNumber numberWithBool:YES];
    self.infoModel.buryCount = [NSString stringWithFormat:@"%d",count];
    [self updateButtonTitle];
    TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
    
    TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
    parameter.aggr_type = self.infoModel.aggrType;
    parameter.item_id = self.infoModel.itemId;
    parameter.group_id = self.infoModel.groupId;
    parameter.ad_id = self.infoModel.adId;
    NSString *unique_id = self.infoModel.groupId ? self.infoModel.groupId : self.infoModel.adId;
    [service burry:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
       SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:YES uniqueIDStr:unique_id);
       SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:count uniqueIDStr:unique_id);
    }];
    
}

- (void)cancelBurryAction
{
    int count = [self.infoModel.buryCount intValue];
    count--;
    self.infoModel.userBuried = [NSNumber numberWithBool:NO];
    self.infoModel.buryCount = [NSString stringWithFormat:@"%d",count];
    [self updateButtonTitle];
    TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
    
    TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
    parameter.aggr_type = self.infoModel.aggrType;
    parameter.item_id = self.infoModel.itemId;
    parameter.group_id = self.infoModel.groupId;
    parameter.ad_id = self.infoModel.adId;
    NSString *unique_id = self.infoModel.groupId ? self.infoModel.groupId : self.infoModel.adId;
    [service cancelBurry:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
        SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:NO uniqueIDStr:unique_id);
        SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:count uniqueIDStr:unique_id);
    }];
    
}

- (void)linkTap:(NSURL*)linkURL UIView:(UIView *)sender{

    if ([[TTRoute sharedRoute] canOpenURL:linkURL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:linkURL];
    }
    else {
        UINavigationController *nv = [TTUIResponderHelper topNavigationControllerFor:sender];
        [SSWebViewController openWebViewForNSURL:linkURL title:@" " navigationController:nv supportRotate:NO];
    }
}


#pragma mark - helper

+ (CGFloat)contentLabelFontSize
{
    return tt_ssusersettingsManager_detailVideoContentFontSize();
}

//Label属性
- (NSDictionary *)contentLabelTextAttributs
{
    if (!_contentLabelTextAttributs) {
        UIFont *font = [UIFont systemFontOfSize:[[self class] contentLabelFontSize]];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineHeightMultiple = 1.3;
        style.paragraphSpacing = .3 * font.lineHeight;
        
        NSMutableDictionary *attributs = [[NSMutableDictionary alloc] initWithCapacity:3];
        [attributs setValue:style forKey:NSParagraphStyleAttributeName];
        [attributs setValue:font forKey:NSFontAttributeName];
        [attributs setValue:SSGetThemedColorWithKey(kColorText3) forKey:NSForegroundColorAttributeName];
        _contentLabelTextAttributs = [attributs copy];
    }
    return _contentLabelTextAttributs;
}

- (NSDictionary *)contentLabelLinkAttributes
{
    if (!_contentLabelLinkAttributes) {
        NSMutableDictionary *linkAttr = [[NSMutableDictionary alloc] initWithCapacity:2];
        [linkAttr setValue:@(NO) forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [linkAttr setValue:SSGetThemedColorWithKey(kColorText5) forKey:NSForegroundColorAttributeName];
        _contentLabelLinkAttributes = [linkAttr copy];
    }
    return _contentLabelLinkAttributes;
}

- (NSDictionary *)contentLabelActiveLinkAttributes
{
    if (!_contentLabelActiveLinkAttributes) {
        NSMutableDictionary *activeLinkAtt = [[NSMutableDictionary alloc] initWithCapacity:2];
        [activeLinkAtt setValue:@(NO) forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [activeLinkAtt setValue:SSGetThemedColorWithKey(kColorText5Highlighted) forKey:NSForegroundColorAttributeName];
        _contentLabelActiveLinkAttributes = [activeLinkAtt copy];
    }
    return _contentLabelActiveLinkAttributes;
}

- (BOOL)showExtendLink
{
    NSString *linkUrl = [self.infoModel.VExtendLinkDic valueForKey:@"url"];
    NSString *appid = [self.infoModel.VExtendLinkDic valueForKey:@"apple_id"];
    BOOL isDownloadApp = [[self.infoModel.VExtendLinkDic valueForKey:@"is_download_app"] boolValue];
    BOOL show = NO;
    if (isDownloadApp) {
        if (appid.length > 0 || linkUrl.length > 0) {
            show = YES;
        }
    }
    else
    {
        if (linkUrl.length > 0) {
            show = YES;
        }
    }
    return show;
}

- (NSString *)uniqueID
{
    return self.infoModel.groupId ? self.infoModel.groupId : self.infoModel.adId;
    
}



@end
