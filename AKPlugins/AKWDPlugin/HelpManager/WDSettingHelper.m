//
//  WDSettingHelper.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/13.
//
//

#import "WDSettingHelper.h"
#import "WDCommonLogic.h"
#import "WDFeedActivityManager.h"

#define kWDSettingHelperUserDefaultKey @"kWDSettingHelperUserDefaultKey"

@interface WDSettingHelper()
@property(nonatomic, strong)NSDictionary * settingDict;

@property (nonatomic, assign) NSInteger listAnswerHasImgTextMaxLineCount;

@property (nonatomic, assign) BOOL isStautsBarStyleDefault;

@end

@implementation WDSettingHelper

- (id)init
{
    self = [super init];
    if (self) {
        self.settingDict = [WDSettingHelper savedWendaInfoDict];
    }
    return self;
}

+ (void)saveWendaAppInfoDict:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kWDSettingHelperUserDefaultKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults]  removeObjectForKey:kWDSettingHelperUserDefaultKey];
    }
    if ([dict valueForKey:@"detail_sliding_type"]) {
        [WDCommonLogic setAnswerDetailShowSlideType:[dict tt_integerValueForKey:@"detail_sliding_type"]];
    }
    if ([dict valueForKey:@"wenda_detail_show_mode"]) {
        [WDCommonLogic setWDNewDetailStyleEnabled:[dict tt_boolValueForKey:@"wenda_detail_show_mode"]];
    }
    if ([dict valueForKey:@"wenda_detail_newpush_disable"]) {
        [WDCommonLogic setWDNewDetailNewPushDisabled:[dict tt_boolValueForKey:@"wenda_detail_newpush_disable"]];
    }
    if ([dict valueForKey:@"wddetail_newnatant_enable"]) {
        [WDCommonLogic setWDDetailNatantNewStyleEnable:[dict tt_boolValueForKey:@"wddetail_newnatant_enable"]];
    }
    if ([dict valueForKey:@"wenda_transform_into_wukong_open_url"]) {
        [WDCommonLogic setWukongURL:[dict tt_stringValueForKey:@"wenda_transform_into_wukong_open_url"]];
    }
    if ([dict tt_stringValueForKey:@"tt_image_host_address"]) {
        [WDCommonLogic setToutiaoImageHost:[dict tt_stringValueForKey:@"tt_image_host_address"]];
    }
    if ([dict valueForKey:@"detail_related_report_style"]) {
        [WDCommonLogic setRelatedReportStyle:[dict valueForKey:@"detail_related_report_style"]];
    }
    if ([dict valueForKey:@"wddetail_read_postion_enable"]) {
        [WDCommonLogic setAnswerReadPositionEnable:[dict tt_boolValueForKey:@"wddetail_read_postion_enable"]];
    }
    if ([dict valueForKey:@"wd_message_dislike_style"]) {
        [WDCommonLogic setWDMessageDislikeNewStyle:[dict tt_boolValueForKey:@"wd_message_dislike_style"]];
    }
    if ([dict tt_dictionaryValueForKey:@"wd_widget_banner"]) {
        [[WDFeedActivityManager sharedInstance] refreshActivityWithDict:[dict tt_dictionaryValueForKey:@"wd_widget_banner"]];
    }
    NSArray *wendaHosts = [dict valueForKey:@"wenda_host_list"];
    if ([wendaHosts isKindOfClass:[NSArray class]]) {
        [self saveWenDaDetailUrlHosts:wendaHosts];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)savedWendaInfoDict
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kWDSettingHelperUserDefaultKey];
    return dict;
}

#pragma mark -- 服务端可控值

/**
 *  页面统计停留时长
 *
 *  @return 需要开始记录的错误值
 */
- (NSTimeInterval)pageStayErrorTime
{
    NSTimeInterval errorStayTime = 60*60*12;
    if ([[_settingDict allKeys] containsObject:@"page_stay_error_time"]) {
        errorStayTime = [[_settingDict objectForKey:@"page_stay_error_time"] doubleValue];
    }
    if (errorStayTime == 0) {
        errorStayTime = 60*60*12; //默认值
    }
    
    return errorStayTime;
}

- (NSInteger)listCellContentMaxLine
{
    NSInteger count = 0;
    if ([[_settingDict allKeys] containsObject:@"list_answer_text_max_count"]) {
        count = [[_settingDict objectForKey:@"list_answer_text_max_count"] integerValue];
    }
    if (count == 0) {
        count = 6;  //默认值
    }
    if (count < 2) {
        count = 2;
    }
    else if (count >= 15) {
        count = 15;
    }
    return count;

}

- (NSInteger)moreListAnswerTextMaxCount
{
    NSInteger count = 0;
    if ([[_settingDict allKeys] containsObject:@"more_list_answer_text_max_count"]) {
        count = [[_settingDict objectForKey:@"more_list_answer_text_max_count"] integerValue];
    }
    if (count == 0) {
        count = 3;  //默认值
    }
    if (count < 2) {
        count = 2;
    }
    else if (count >= 15) {
        count = 15;
    }
    return count;
}

- (NSInteger)listAnswerHasImgTextMaxCount
{
    if (_listAnswerHasImgTextMaxLineCount != 0) return _listAnswerHasImgTextMaxLineCount;
    NSInteger count = 0;
    if ([[_settingDict allKeys] containsObject:@"list_answer_has_img_text_max_count"]) {
        count = [[_settingDict objectForKey:@"list_answer_has_img_text_max_count"] integerValue];
    }
    if (count == 0) {
        count = 3;  //默认值
    }
    if (count < 2) {
        count = 2;
    }
    else if (count >= 15) {
        count = 15;
    }
    _listAnswerHasImgTextMaxLineCount = count;
    return _listAnswerHasImgTextMaxLineCount;
}

- (NSInteger)minAnswerTextLength
{
    NSInteger count = 0;
    if ([[_settingDict allKeys] containsObject:@"min_answer_length"]) {
        count = [[_settingDict objectForKey:@"min_answer_length"] integerValue];
    }
    if (count == 0) {
        count = 1;  //默认值
    }

    return count;
}

#pragma mark -- 服务端可控文案

- (NSString *)listSectionTitleText
{
    NSString * result = nil;
    result = [_settingDict objectForKey:@"list_section_title_text"];
    if (isEmptyString(result)) {
        result = @"个回答";
    }
    return result;
}

- (NSString *)listQuestionHeaderAnswerCountText
{
    NSString * result = nil;
    result = [_settingDict objectForKey:@"list_question_header_answer_count_text"];
    if (isEmptyString(result)) {
        result = @"个回答";
    }
    return result;
}

- (NSString *)postAnswerPlaceholder
{
    NSString * result = [_settingDict objectForKey:@"post_answer_placeholder"];
    if (!isEmptyString(result)) {
        return result;
    }

    return @"不认真的回答会被折叠哦~";
}

- (NSString *)quickPostAnswerPlaceholder
{
    NSString * result = [_settingDict objectForKey:@"quick_post_answer_placeholder"];
    if (!isEmptyString(result)) {
        return result;
    }
    
    return @"请输入回答";
}

- (NSString *)listMoreAnswerCountText
{
    NSString * result = nil;
    result = [_settingDict objectForKey:@"list_more_answer_count_text"];
    if (isEmptyString(result)) {
        result = @"查看折叠回答";
    }
    return result;
}

- (NSString *)minAnswerLengthText
{
    NSString *result = nil;
    result = [_settingDict objectForKey:@"min_answer_length_text"];
    if (isEmptyString(result)) {
        result = [NSString stringWithFormat:@"回答字数不能低于%lu个字", (unsigned long)[self minAnswerTextLength]];
    }
    return result;
}

#pragma mark - 举报原因选项
- (NSArray *)wendaAnswerReportSetting
{
    return [_settingDict objectForKey:@"report_answer_settings"];
}

- (NSArray *)wendaQuestionReportSetting
{
    return [_settingDict objectForKey:@"report_question_settings"];
}

#pragma mark - 问答的CDN HOST

+ (void)saveWenDaDetailUrlHosts:(NSArray *)detailHosts
{
    if (!SSIsEmptyArray(detailHosts)) {
        [[NSUserDefaults standardUserDefaults] setObject:detailHosts forKey:@"wenda_host_list"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)wendaDetailURLHosts
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"wenda_host_list"];
}

+ (NSArray *)defaultWendaDetailURLHosts
{
    return @[@"wd3.pstatp.com", @"wd3.bytecdn.cn"];
}

- (BOOL)isWenSwithOpen
{
    BOOL result = NO;
    NSNumber *resultNumber = [_settingDict objectForKey:@"extra_switch"];
    if ([resultNumber isKindOfClass:[NSNumber class]]) {
        result = [resultNumber boolValue];
    }
    return result;
}

#pragma mark - 是否显示分成

- (BOOL)isQuestionRewardUserViewShow {
    if (_settingDict[@"enable_profit"]) {
        return [_settingDict[@"enable_profit"] boolValue];
    }
    return NO;
}

#pragma mark - 是否显示分享有礼

- (BOOL)isQuestionShareRewardUserViewShow {
    if (_settingDict[@"enable_share_profit"]) {
        return [_settingDict[@"enable_share_profit"] boolValue];
    }
    return NO;
}

#pragma mark - 问答列表页

- (BOOL)isQuestionShowPicture
{
    if (_settingDict[@"question_brow_show_picture"]) {
        return [_settingDict[@"question_brow_show_picture"] boolValue];
    }
    return YES;
}

#pragma mark - 提问业务

- (BOOL)isPostAnswerVideo
{
    if (_settingDict[@"post_answer_video_switch"]) {
        return [_settingDict[@"post_answer_video_switch"] boolValue];
    }
    return YES;
}

- (NSString *)wendaCategoryPlaceHolder
{
    NSString *result = [_settingDict objectForKey:@"search_placeholder"];
    if (isEmptyString(result)) {
        result = @"搜一搜你想问的问题";
    }
    return result;
}

- (NSArray *)wendaPostFirstHintArray
{
    NSArray *result = [_settingDict objectForKey:@"post_question_first"];
    if (result.count != 3) {
        result = @[@"为了让问题广泛传播，我们可能会修改你的问题及描述",
                   @"鼓励提出可供大家讨论的问题",
                   @"每天最多可提问3次"];
    }
    return result;
}

- (NSString *)wendaPostQuestionPlaceHolder
{
    NSString *result = [_settingDict objectForKey:@"post_question_title_placeholder"];
    if (isEmptyString(result)) {
        result = @"请输入问题，最多40个字";
    }
    return result;
}

- (NSInteger)maxQuestionTitleCharaterNumber
{
    if (_settingDict[@"post_question_title_max"]) {
        return [_settingDict[@"post_question_title_max"] integerValue];
    }
    
    return 40;
}

- (NSInteger)minQuestionTitleCharaterNumber
{
    if (_settingDict[@"post_question_title_min"]) {
        return [_settingDict[@"post_question_title_min"] integerValue];
    }
    
    return 4;
}

- (NSString *)wendaPostQuestionHintTitle
{
    NSString *result = [_settingDict objectForKey:@"post_question_good_question_tips"];
    if (isEmptyString(result)) {
        result = @"什么是一个好问题？";
    }
    return result;
}

- (NSString *)wendaPostQuestionHintSchema
{
    NSString *result = [_settingDict objectForKey:@"post_question_good_question_url"];
    if (isEmptyString(result)) {
        result = @"sslocal://detail?groupid=6316300819861012738";
    }
    return result;
}

- (NSString *)postQuestionDescPlaceHolder
{
    NSString *result = [_settingDict objectForKey:@"post_question_content_placeholder"];
    if (isEmptyString(result)) {
        result = @"添加问题描述，描述不少于10个字";
    }
    return result;
}


- (NSInteger)maxQuestionDescCharaterNumber
{
    if (_settingDict[@"post_question_content_max"]) {
        return [_settingDict[@"post_question_content_max"] integerValue];
    }
    
    return 500;
}

- (NSInteger)minQuestionDescCharaterNumber
{
    if (_settingDict[@"post_question_content_min"]) {
        return [_settingDict[@"post_question_content_min"] integerValue];
    }
    
    return 10;
}

- (BOOL)isDescRequired{
    if (_settingDict[@"post_question_must_have_content"]) {
        return [_settingDict[@"post_question_must_have_content"] boolValue];
    }
    return YES;
}

- (NSString *)postQuestionTagPlaceHolder
{
    NSString *result = [_settingDict objectForKey:@"post_question_tag_placeholder"];
    if (isEmptyString(result)) {
        result = @"添加标签让更多人看到问题";
    }
    return result;
}

#pragma mark - 详情页逻辑

- (BOOL)wdDetailShowMode
{
    return [WDCommonLogic isWDNewDetailStyleEnabled];
}

- (BOOL)wdDetailNewPushDisabled
{
    return [WDCommonLogic isWDNewDetailNewPushDisabled];
}

- (BOOL)wdDetailStatusBarStyleIsDefault {
    return _isStautsBarStyleDefault;
}

- (void)wdSetDetailStatusBarStyleIsDefault:(BOOL)isDefault {
    _isStautsBarStyleDefault = isDefault;
}

- (AnswerDetailShowSlideType)wdAnswerDetailShowSlideType {
    return [WDCommonLogic answerDetailShowSlideType];
}

- (NSUInteger)wendaDetailHeaderViewStyle {
    return 0;
}

#pragma mark - Feed顶部AB，是否露出我的问答

- (BOOL)isFeedHeaderTextType
{
    if ([_settingDict objectForKey:@"feed_header_text_type"]) {
        return [_settingDict tt_boolValueForKey:@"feed_header_text_type"];
    }
    return YES;
}

@end
