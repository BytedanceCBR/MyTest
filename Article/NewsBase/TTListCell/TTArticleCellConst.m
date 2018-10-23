//
//  TTArticleCellConst.m
//  Article
//
//  Created by 杨心雨 on 16/8/18.
//
//

#import "TTUISettingHelper.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"
#import "TTVerifyIconHelper.h"
#import "TTThemeConst.h"
#import "NewsUserSettingManager.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

// MARK: 间距
/** 顶部间距 */
inline CGFloat kPaddingTop() {
    return 15.f;
}

/** 顶部间距(置顶样式) */
inline CGFloat kPaddingStickTop(){
    return 12.f;
}

/** 顶部间距(U11样式) */
inline CGFloat kPaddingUFTop() {
    return 14.f;
}

/** 底部间距 */
inline CGFloat kPaddingBottom() {
    return 15.f;
}

/** 底部间距(置顶样式) */
inline CGFloat kPaddingStickBottom() {
    return 12.f;
}

/** 底部间距(u11样式) */
inline CGFloat kPaddingUFBottom() {
    return 14.f;
}

/** 左部间距 */
inline CGFloat kPaddingLeft() {
    return 15.f;
}

/** 右部间距 */
inline CGFloat kPaddingRight() {
    return 15.f;
}

/*功能区顶部文案和头像间距*/
inline CGFloat kPaddingTopLabelToAavatarView() {
    return 12.f;
}

/** 功能区底部间距 */
inline CGFloat kPaddingFunctionBottom() {
    return 8.f;
}

/** 标题与更多间距(横向) */
inline CGFloat kPaddingTitleToMore() {
    return 15.f;
}

/** 标签与标题间距(横向) */
inline CGFloat kPaddingTagToTitle() {
    return 6.f;
}

/** 标题与摘要间距(纵向) */
inline CGFloat kPaddingTitleToAbstract() {
    return 8.f;
}

/** 标题与图片(视频)间距(横向) */
inline CGFloat kPaddingTitleToPic() {
    return 15.f;
}

/** 图片(视频)顶部间距 */
inline CGFloat kPaddingPicTop() {
    return 8.f;
}

/** 图片（评论cell）顶部间距 */
inline CGFloat KUFPaddingCommentPicTop() {
    return 12.f;
}

/** 标题(摘要)与评论间距(纵向) */
inline CGFloat kPaddingTitleOrAbstractToComment() {
    return 8.f;
}

/** 图片(视频)与评论间距(纵向) */
inline CGFloat kPaddingPicToComment() {
    return 8.f;
}

/** 信息栏顶部间距 */
inline CGFloat kPaddingInfoTop() {
    return 12.f;
}

/** 创意通投顶部间距 */
inline CGFloat kPaddingActionADTop() {
    return 8.f;
}

/** 信息栏保护间距 */
inline CGFloat kPaddingInfoConstTop() {
    return 4.f;
}

// MARK: - Cell
/** 背景色 */
inline NSString* kCellBackgroundColor() {
    return kColorBackground4;
}

// MARK: - 功能区控件
/** 喜欢与来源间距 */
inline CGFloat kFunctionViewPaddingLikeToSource() {
    return 12.f;
}

/** 来源图片与来源间距 */
inline CGFloat kFunctionViewPaddingSourceImageToSource() {
    return 6.f;
}

/** 来源图片和来源间距 */
inline CGFloat kUFPaddingSourceImageToSource() {
    return 8.f;
}

/** 来源大图和来源间距 */
inline CGFloat kUFS2PaddingSourceImageToSource() {
    return 10.f;
}
/** 喜欢字号 */
inline CGFloat kLikeViewFontSize() {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: return 11;
        case TTDeviceMode568:
        case TTDeviceMode480: return 10;
    }
}

/** 喜欢字体颜色 */
inline NSString* kLikeViewTextColor() {
    return kColorText5;
}

/** 来源图片边长 */
inline CGFloat kSourceViewImageSide() {
    return 19.f;
}

/** 来源图片边长 */
inline CGFloat kUFSourceViewImageSide() {
    return 30.f;
}

/** 来源图片底部间距 */
inline CGFloat kUFSourceViewBottomPadding() {
    return 10.f;
}

/** 来源图片背景色 */
inline NSString* kSourceViewImageBackgroundColor() {
    return kColorBackground3;
}

/** 来源图片描边色 */
inline NSString* kSourceViewImageBorderColor() {
    return kColorLine1;
}

/** 来源字号 */
inline CGFloat kSourceViewFontSize() {
    return 12.f;
}

/** u11来源字号 */
inline CGFloat kUFSourceLabelFontSize() {
    return 14.f;
}

/** 来源字体颜色 */
inline NSString* kSourceViewTextColor() {
    return kColorText1;
}

inline NSString* kVerifiedContentSeprateLineColor() {
    return kColorLine7;
}

/** 认证信息字号 */
inline CGFloat kVerifiedContentLabelFontSize() {
    return 12.f;
}

/** 认证信息字体颜色 */
inline NSString* kVerifiedContentLabelTextColor() {
    return kColorText3;
}

/** 认证信息已读字体颜色 */
inline NSString* kVerifiedContentLabelHasReadTextColor() {
    return kColorText3Highlighted;
}

/** 来源高亮字体颜色 */
inline NSString* kSourceViewHighlightedTextColor() {
    return kColorText1Highlighted;
}

// MARK: - 更多控件
/** 更多控件边长 */
inline CGFloat kMoreViewSide() {
    return 12.f;
}

/** 更多控件扩展 */
inline CGFloat kMoreViewExpand() {
    return 11.f;
}

inline CGFloat kMoreViewTopPadding() {
    return 15.f;
}

inline CGFloat kMoreViewRightPadding() {
    return 15.f;
}


// MARK: - 标题控件
/** 标题字号 */
inline CGFloat kTitleViewFontSize() {
    if ([TTUISettingHelper cellViewTitleFontSizeControllable]) {
        return [TTUISettingHelper cellViewTitleFontSize];
    }
    CGFloat size = 0;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: size = 19; break;
        case TTDeviceMode568:
        case TTDeviceMode480: size = 17; break;
    }
    return [TTArticleCellHelper settingSize:size];
}

/** 标题字号(置顶样式) */
inline CGFloat kTitleViewStickFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: size = 15; break;
        case TTDeviceMode568: size = 13; break;
        case TTDeviceMode480: size = 14; break;
    }
    return [TTArticleCellHelper settingSize:size];
}

/** 标题字体颜色 */
inline NSString* kTitleViewTextColor() {
    return kColorText1;
}

inline NSString* kTitleViewHasReadTextColor() {
    return kColorText1Highlighted;
}

/** 标题行高 */
inline CGFloat kTitleViewLineHeight() {
    return [TTArticleCellHelper lineHeight:(kTitleViewFontSize() * 50 / 38)];
}

/** 标题行高(置顶样式) */
inline CGFloat kTitleViewStickLineHeight() {
    return [TTArticleCellHelper lineHeight:(kTitleViewStickFontSize() * 1.4)];
}

/** 标题行数 */
inline NSInteger kTitleViewLineNumber() {
    return [[TTCellSetting shareSetting] title];
}

/** 标题行数(无摘要右小图) */
inline NSInteger kTitleViewSpecialLineNumber() {
    return [[TTCellSetting shareSetting] titleSpecial];
}

// MARK: - 摘要控件
/** 摘要字号 */
inline CGFloat kAbstractViewFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: size = 16; break;
        case TTDeviceMode568:
        case TTDeviceMode480: size = 14; break;
    }
    return [TTArticleCellHelper settingSize:size];
}

/** 摘要字体颜色 */
inline NSString* kAbstractViewTextColor() {
    return kColorText2;
}

/** 摘要已读字体颜色 */
inline NSString* kAbstractViewHadReadTextColor() {
    return kColorText2Highlighted;
}

/** 摘要行高 */
inline CGFloat kAbstractViewLineHeight() {
    return [TTArticleCellHelper lineHeight:(kAbstractViewFontSize() * 1.3)];
}

/** 摘要行数 */
inline NSInteger kAbstractViewLineNumber() {
    return [[TTCellSetting shareSetting] abstract];
}

// MARK: - 图片(视频)控件
/** 图片(视频)内部间距 */
inline CGFloat kPicViewPaddingInner() {
    return 1.f;
}

inline CGFloat kSquareViewPaddingInner() {
    return 7.f;
}

/** 图片(视频)背景色 */
inline NSString* kPicViewBackgroundColor() {
    return kColorBackground3;
}

/** 图片(视频)描边色 */
inline NSString* kPicViewBorderColor() {
    return kColorLine1;
}

/** 信息视图右边距 */
inline CGFloat kPicMessageViewPaddingRight() {
    return 4.f;
}

inline CGFloat kPicMessageViewPaddingRightVideo() {
    return 0.f;
}

inline CGFloat kPicMessageViewPaddingRightPhoto() {
    return 10.f;
}

/** 信息视图下边距 */
inline CGFloat kPicMessageViewPaddingBottom() {
    return 4.f;
}

/** 信息视图内部水平边距 */
inline CGFloat kPicMessageViewPaddingHorizontal() {
    return 6.f;
}

/** 信息视图图片与文字间距 */
inline CGFloat kPicMessageViewPaddingImageToLabel() {
    return 2.f;
}

/** 信息视图固定高度 */
inline CGFloat kPicMessageViewHeight() {
    return 20.f;
}

/** 信息视图标准宽度 */
inline CGFloat kPicMessageViewWidth() {
    return 44.f;
}

/** 信息视图圆角半径 */
inline CGFloat kPicMessageViewCornerRadius() {
    return 10.f;
}

/** 信息视图背景色 */
inline NSString* kPicMessageViewBackgroundColor() {
    return kColorBackground15;
}

/** 信息视图文字字号 */
inline CGFloat kPicMessageViewFontSize() {
    return 10.f;
}

/** 信息视图文字颜色 */
inline NSString* kPicMessageViewTextColor() {
    return kColorText12;
}

// MARK: - 评论控件
/** 评论字号 */
inline CGFloat kCommentViewFontSize() {
    return [TTArticleCellHelper settingSize:14.f];
}

/** 评论字体颜色 */
inline NSString* kCommentViewTextColor() {
    return kColorText2;
}

/** 评论已读字体颜色 */
inline NSString* kCommentViewHasReadTextColor() {
    return kColorText2Highlighted;
}

/** 评论用户字体颜色 */
inline NSString* kCommentViewUserTextColor() {
    return kColorText5;
}

/** 评论用户字体高亮颜色 */
inline NSString* kCommentViewUserTextHighlightedColor() {
    return kColorText5Highlighted;
}

/** 评论行高 */
inline CGFloat kCommentViewLineHeight() {
    return [TTArticleCellHelper lineHeight:(kCommentViewFontSize() * 1.5)];
}

/** 评论行数 */
inline NSInteger kCommentViewLineNumber() {
    return [[TTCellSetting shareSetting] comment];
}

// MARK: - 信息栏控件
inline CGFloat kInfoViewHeight() {
    return 16.f;
}

inline CGFloat kInfoViewFontSize() {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: return 11;
        case TTDeviceMode568:
        case TTDeviceMode480: return 10;
    }
}

// MARK: - 标签控件
/** 标签字体大小 */
inline CGFloat kTagViewFontSize() {
    return 10.f;
}

/** 标签单字宽度 */
inline CGFloat kTagViewOneWordWidth() {
    return 14.f;
}

/** 标签双字宽度 */
inline CGFloat kTagViewTwoWordsWidth() {
    return 24.f;
}

/** 标签水平间距 */
inline CGFloat kTagViewPaddingHorizontal() {
    return 2.f;
}

/** 标签高度 */
inline CGFloat kTagViewHeight() {
    return 14.f;
}

/** 标签圆角 */
inline CGFloat kTagViewCornerRadius() {
    return 3.f;
}

/** 标签红色字 */
inline NSString* kTagViewTextColorRed() {
    return kColorText4;
}

/** 标签红描边 */
inline NSString* kTagViewLineColorRed() {
    return kColorLine4;
}

/** 标签蓝色字 */
inline NSString* kTagViewTextColorBlue() {
    return kColorBlueTextColor;
}

/** 标签蓝描边 */
inline NSString* kTagViewLineColorBlue() {
    return kColorBlueBorderColor;
}

//MARK: - 底部Action控件
inline CGFloat kPaddingTopOfActionView() {
    return 10.f;
}

inline CGFloat kActionViewHeight() {
    return 15.f;
}

inline NSString* kActionViewCommentButtonTextColor() {
    return kColorText9;
}

inline CGFloat kPaddingBetweenDiggButtonAndCommentBUtton() {
    return 60.f;
}

inline NSString* kActionViewTimeLabelColor() {
    return kColorText9;
}

// MARK: - 底部分割线
inline NSString* kBottomLineViewBackgroundColor() {
    return kColorLine1;
}

// MARK: - 功能菜单
/** 帖子标题行数 */
inline NSInteger kThreadTitleLineNumber() {
    return [[TTCellSetting shareSetting] topicTitle];
}

/** 帖子内容行数(文章样式) */
inline NSInteger kThreadStyle1ContentLineNumber() {
    return [[TTCellSetting shareSetting] topic];
}

/** 帖子内容行数(帖子样式) */
inline NSInteger kThreadStyle2ContentLineNumber() {
    return [[TTCellSetting shareSetting] topicContent];
}

/** */
inline NSInteger kThreadCommentLineNumber() {
    return [[TTCellSetting shareSetting] topicComment];
}

/** 视频cell标题字号 */
static NSDictionary *videoCellFontSizes = nil;

inline CGFloat kVideoCellTitleFontSize() {
    if (!videoCellFontSizes) {
        videoCellFontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                               @"iPhone667": @[@16,@18,@20,@23],
                               @"iPhone736" : @[@16, @18, @20, @23],
                               @"iPhone" : @[@14, @16, @18, @21]};
    }
    
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [videoCellFontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];;
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

inline CGFloat kRedPacketSubSubscribeButtonWidth() {
    return 72.f;
}

/** u11关注按钮宽度 */
inline CGFloat kUFSubscribeButtonWidth() {
    return 42.f;
}

/** u11关注按钮高度 */
inline CGFloat kUFSubscribeButtonHeight() {
    return 28.f;
}

/** u11关注按钮右边距 */
inline CGFloat kUFSubscribeButtonRightPadding() {
    return 15.f;
}

/** u11关注按钮字号 */
inline CGFloat kUFSubscribeButtonTitleFontSize() {
    return 14.f;
}

/** u11加v的icon的大小，需要传入认证类型 */
inline CGSize kUFVerifiedImageViewSize(NSString *userAuthInfo) {
    if (isEmptyString(userAuthInfo)) {
        return CGSizeZero;
    }
    
    NSString *verifyType = [TTVerifyIconHelper verifyTypeOfVerifyInfo:userAuthInfo];
    CGSize size = [TTVerifyIconHelper labelIconSizeOfType:verifyType];
    
    if (size.height > 13.f) {
        size.width = size.width / size.height * 13.f;
        size.height = 13.f;
    }
    
    return size;
}

/** u11竖向分隔线高度 */
inline CGFloat kUFSeprateLineHeight() {
    return 11.f;
}

/** u11加v的左右间距 */
inline CGFloat kUFVerifiedImageViewPadding() {
    return 3.f;
}

/** u11推荐理由左侧间距 */
inline CGFloat kUFRecommendLabelLeftPadding() {
    return 5.0f;
}

/** u11品牌露出间距 */
inline CGFloat kUFIconsShowingPadding() {
    return 4.0f;
}

/** 竖向分割线左右间距*/
inline CGFloat kUFSeprateLinePadding() {
    return 4.f;
}

/** u11顶踩功能区高度 */
inline CGFloat kUFFunctionViewHeight() {
    return 18.f;
}

/** u11信息栏距离标题的间距 */
inline CGFloat kUFPaddingSourceImageToTitle() {
    return 10.f;
}

/** u11大图与顶踩功能区间距 */
inline CGFloat kUFPaddingPicBottom() {
    return 9.f;
}

/** u11顶和评论字号 */
inline CGFloat kUFFunctionViewFontSize() {
    return 12.f;
}

/** 播放按钮边长 */
inline CGFloat kUFPlayButtonSide() {
    return 60.f;
}

/** u11ugc动态cell上，评论内容字号 */
inline CGFloat kUFCommentContentFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: size = 17; break;
        case TTDeviceMode568:
        case TTDeviceMode480: size = 15; break;
    }
    return [TTArticleCellHelper settingSize:size];
}

/** u11ugc动态cell上，评论内容行高 */
inline CGFloat kUFCommentContentLineHeight() {
     return [TTArticleCellHelper lineHeight:(kUFCommentContentFontSize() * 1.4f)];
}

/** u11ugc动态cell上，评论内容行数 */
inline NSInteger kUFCommentContentLineNumber() {
    return 8.f;
}

/** u11ugc动态cell上，新闻内容下的背景高度 */
inline CGFloat kUFBackgroundViewHeight() {
    return 68.f;
}

/** u11ugc动态cell上，左图边长 */
inline CGFloat kUFLeftPicViewSide() {
    return 68 - 2 * [TTDeviceHelper ssOnePixel];
}

/** u11ugc动态cell上，左图与背景的左边间距 */
inline CGFloat kUFLeftPicViewLeftPadding() {
    return [TTDeviceHelper ssOnePixel];
}

/** u11ugc动态cell上，左图与背景的左边间距 */
inline CGFloat kUFLeftPicViewTopPadding() {
    return [TTDeviceHelper ssOnePixel];
}

/** u11ugc动态cell上，左图与右边标题的左边间距 */
inline CGFloat kUFLeftPicViewRightPadding() {
    return 15.f;
}

/** u11ugc动态cell上，标题与背景的右边的间距 */
inline CGFloat kUFTitleRightPaddingToBack() {
    return 7.5f;
}

/** u11ugc动态cell上，标题的字号 */
inline CGFloat kUFDongtaiTitleFontSize() {
    if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]){
        return 14.f;
    }
    return 16.f;
}

/** u11ugc动态cell上，标题的字号 */
inline CGFloat kUFS1DongtaiTitleFontSize() {
    return 16.f;
}

/** u11ugc动态cell上，标题的行高 */
inline CGFloat kUFDongtaiTitleLineHeight() {
    return [TTArticleCellHelper lineHeight:kUFDongtaiTitleFontSize()*1.2];
}

/** u11ugc动态cell上，标题的行高 */
inline CGFloat kUFS1DongtaiTitleLineHeight() {
    if ([TTDeviceHelper is480Screen]){
        return 21.f;
    }
    return 24.f;
}

/** u11ugc动态cell上，标题的行数 */
inline NSInteger kUFDongtaiTitleLineNumber() {
    return 2;
}

/** u11分割条的高度 */
inline CGFloat kUFSeprateViewHeight() {
    return 6.f;
}

/** u11帖子正文字号 */
inline CGFloat kUFThreadContentFontSize() {
    CGFloat size = 0;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode667: size = 17; break;
        case TTDeviceMode568:
        case TTDeviceMode480: size = 15; break;
    }
    return [TTArticleCellHelper settingSize:size];
}

/** u11帖子正文行高 */
inline CGFloat kUFThreadContentLineHeight() {
    return [TTArticleCellHelper lineHeight:kUFThreadContentFontSize()*1.4];
}

/** u11帖子地理位置字号 */
inline CGFloat kUFThreadLocationFontSize() {
    if ([TTDeviceHelper isScreenWidthLarge320]){
        return 12.f;
    }
    return 10.f;
}

/** u11帖子地理位置顶部间距 */
inline CGFloat kUFThreadLocationTopPadding() {
    return 7.0f;
}

/** u11帖子地理位置高度 */
inline CGFloat kUFThreadLocationHeight() {
    return 14.f;
}

/** u11帖子地理位置左边距 */
inline CGFloat kUFThreadLocationLeftPadding() {
    return 3.f;
}

/** u11帖子功能区头部间距 */
inline CGFloat kUFThreadFunctionTopPadding() {
    return 10.f;
}

/** u11帖子webpage上边距 */
inline CGFloat kUFThreadWebpageTopPadding() {
    return 5.f;
}

/** u11帖子webpage高度 */
inline CGFloat kUFThreadWebpageHeight() {
    return 68.f;
}

/** u11帖子webpage标题字体大小 */
inline CGFloat kUFThreadWebpageTitleFontSize() {
    if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]){
        return 14.f;
    }
    return 16.f;
}

/** u11帖子webpage描述字体大小 */
inline CGFloat kUFThreadWebpageDescribeFontSize() {
    return 12.f;
}

/** u11帖子转发内容顶部间距 */
inline CGFloat kUFThreadForwardItemTopPadding() {
    return 5.f;
}

/** u11帖子转发内容内部垂直间距 */
inline CGFloat kUFThreadForwardItemInnerVerticalPadding() {
    return 4.f;
}

/** u11转发内容被删除label顶部间距 */
inline CGFloat kUFThreadForwardedItemStatusLabelTopPadding() {
    return 7.f;
}

/** u11转发内容被删除label高度 */
inline CGFloat kUFThreadForwardedItemStatusLabelHeight() {
    return 50.f;
}

/** u11S1不感兴趣按钮右边距 */
inline CGFloat kUFS1ThreadUnterestRightPadding(){
    return 15.f;
}

/** u11S1不感兴趣按钮大小 */
inline CGSize kUFS1ThreadUnterestButtonSize(){
    return CGSizeMake(60.f, 44.f);
}

/** u11S1关注按钮与不感兴趣按钮之间的间距 */
inline CGFloat kUFS1FollowBtnPaddingToUnInterestBtn(){
    return 10.f;
}

/** u11S1互动数据的字体大小 */
inline CGFloat kUFS1InteractionInfoFontSize(){
    if ([TTDeviceHelper isScreenWidthLarge320]){
        return 12.f;
    }
    return 10.f;
}

/** u11S1互动数据左边距 */
inline CGFloat kUFS1InteractionInfoLeftPadding(){
    if ([TTDeviceHelper isPadDevice]){
        return 14.f;
    }
    return 8.f;
}

/** u11S1互动数据与定位信息的上间距 */
inline CGFloat kUFS1InteractionInfoTopPaddingLocationLabel(){
    return 8.f;
}

/** u11S1点赞区域与上层的间距 */
inline CGFloat kUFS1ActionRegionTopPadding(){
    return 7.f;
}

/** u11S1点赞区域高度 */
inline CGFloat kUFS1ActionRegionHeight(){
    return 36.f;
}

/** u11S1点赞区域中间间距线的高度 */
inline CGFloat kUFS1ActionRegionCenterSeparateViewHeight(){
    return 0;
}

/** u11S1点赞按钮的高度 */
inline CGFloat kUFS1DiggButtonHeight(){
    return 24.f;
}

/** u11S1点赞按钮的宽度 */
inline CGFloat kUFS1DiggButtonWidth(){
    return 41.f;
}

/** u11S1评论按钮的高度 */
inline CGFloat kUFS1CommentButtonHeight(){
    return 24.f;
}

/** u11S1评论按钮的宽度 */
inline CGFloat kUFS1CommentButtonWidth(){
    return 53.f;
}

/** u11S1大图与文字区间距 */
inline CGFloat kUFS1PaddingPicBottom() {
    return 5.f;
}

/** u11S2信息栏人名与认证信息上下间距 */
inline CGFloat kUFS2VerifiedLabelTopPadding(){
    return 3.f;
}

/** u11S2加v的左右间距 */
inline CGFloat kUFS2VerifiedImageViewPadding(){
    return 4.f;
}

/** U11S2来源图片边长 */
inline CGFloat kUFS2SourceViewImageSide(){
    return 36.f;
}

/** U11S2名字的上边距 */
inline CGFloat kUFS2NameLabelTopPadding(){
    return 14.f;
}

/** U11S2信息栏距离标题的间距 */
inline CGFloat kUFS2PaddingSourceImageToContent(){
    return 7.f;
}

/** 微头条图片之间的间距 */
inline CGFloat kUFW1PaddingImageView(){
    return 3.f;
}

inline CGFloat kUFWenDaButtonWidth(){
    return 53;
}

inline CGFloat kUFWenDaButtonHeight(){
    return 20;
}

inline CGFloat kUFWenDaSourceLabelFontSize(){
    return 14;
}

inline CGFloat kUFWenDaSourceLabelLeftPadding(){
    return 8;
}

// MARK: - Other
@implementation TTCellSetting

+ (instancetype)shareSetting {
    static TTCellSetting *ttCellSetting;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ttCellSetting = [[TTCellSetting alloc] init];
    });
    return ttCellSetting;
}

- (NSInteger)titleSpecial {
    static NSInteger titleSpecial;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titleSpecial = [SSCommonLogic getUgcCellLineNumber:0];
    });
    return titleSpecial;
}

- (NSInteger)title {
    static NSInteger title;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        title = [SSCommonLogic getUgcCellLineNumber:1];
    });
    return title;
}

- (NSInteger)abstract {
    static NSInteger abstract;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        abstract = [SSCommonLogic getUgcCellLineNumber:2];
    });
    return abstract;
}

- (NSInteger)topic {
    static NSInteger topic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topic = [SSCommonLogic getUgcCellLineNumber:3];
    });
    return topic;
}

- (NSInteger)comment {
    static NSInteger comment;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        comment = [SSCommonLogic getUgcCellLineNumber:4];
    });
    return comment;
}

- (NSInteger)topicComment {
    static NSInteger topicComment;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topicComment = [SSCommonLogic getUgcCellLineNumber:5];
    });
    return topicComment;
}

- (NSInteger)topicTitle {
    static NSInteger topicTitle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topicTitle = [SSCommonLogic getUgcCellLineNumber:6];
    });
    return topicTitle;
}

- (NSInteger)topicContent {
    static NSInteger topicContent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topicContent = [SSCommonLogic getUgcCellLineNumber:7];
    });
    return topicContent;
}

@end
