//
//  TTProfileThemeConstants.h
//  Article
//
//  Created by it-test on 8/5/16.
//
//


#ifndef TTProfileThemeConstants_h
#define TTProfileThemeConstants_h


/**
 * Spacing and font size
 */
#define kTTProfileInsetTop    (20.f/2)
#define kTTProfileInsetLeft   (30.f/2)
#define kTTProfileInsetRight  (30.f/2)

#define kTTProfileArrowInsetRight (30.f/2)


#define kTTProfileSpacingOfSection (8)
#define kTTProfileCellHeight       (94.f/2)
#define kTTProfil eTopCellHeight    (142.f/2)
#define kTTProfilePhotoCarouselHeight    (82.f)

#define kTTProfileSpacingOfTextAndContent   (30.f/2)
#define kTTProfileSpacingOfContentAndArrow  (16.f/2)

#define kTTProfileTitleFontSize    (34.f/2) // 左边的文本
#define kTTProfileTitleColorKey    (kColorText1)

#define kTTProfileContentFontSize  (28.f/2) // 右边的文本
#define kTTProfileContentColorKey  (kColorText3)

#define kTTProfileAddAuthFontSize (24.f/2) //头条号认证文本

#define kTTProfileUserAvatarInsetTop (152.f/2)
#define kTTProfileUserAvatarWidth    [TTDeviceUIUtils tt_newPadding:132.f/2]
#define kTTProfileUserAvatarHeight   [TTDeviceUIUtils tt_newPadding:132.f/2]
#define kTTProfileUserAvatarBorderColor  (@"0xffffff") // nonused

//profile header:more button
#define kTTProfileMoreButtonRightMargin [TTUIResponderHelper screenSize].width / 375.f * 30.f/2

// profile header: username
#define kTTProfileUsernameFontSize [TTDeviceUIUtils tt_newFontSize:34.f/2]
#define kTTProfileShowInfoTopOffset [TTDeviceUIUtils tt_newPadding:10.f/2]
#define kTTProfileShowInfoTemporaryTopOffset [TTDeviceUIUtils tt_newPadding:15.f/2]
#define kTTProfileUsernameTemporaryBottomOffset [TTDeviceUIUtils tt_newPadding:21.f/2]
#define kTTProfileFollowersButtonTopOffset [TTDeviceUIUtils tt_newPadding:12.f/2]
#define kTTProfileNameContainerSubtitleFontSize [TTDeviceUIUtils tt_newFontSize:24.f/2]
#define kTTProfileUsernameColorKey (kColorText10)

// profile header: visitor information
#define kTTProfileLineHeight          (80.f/2)
#define kTTProfileHintLabelOffset     ([TTDeviceHelper isPadDevice] ? [TTUIResponderHelper screenSize].width / 375.f * 35.f/2 : [TTDeviceUIUtils tt_newPadding:35.f/2])
#define kTTProfileLoginButtonOffset   ([TTDeviceHelper isPadDevice] ? [TTUIResponderHelper screenSize].width / 375.f * 50.f/2 : [TTDeviceUIUtils tt_newPadding:50.f/2])
#define kTTProfileVisitorInsetBotttom [TTDeviceUIUtils tt_newPadding:26.f/2]
#define kTTProfileAvatarLeftMargin    ([TTDeviceHelper isPadDevice] ? [TTUIResponderHelper screenSize].width / 375.f * 40.f/2 : [TTDeviceUIUtils tt_newPadding:40.f/2])
#define kTTProfileAvatarBottomMargin  ([TTDeviceHelper isPadDevice] ? [TTUIResponderHelper screenSize].width / 375.f * 46.f/2 : [TTDeviceUIUtils tt_newPadding:46.f/2])
#define kTTProfileAvatarTemporaryBottomMargin  ([TTDeviceHelper isPadDevice] ? [TTUIResponderHelper screenSize].width / 375.f * 57.f/2 : [TTDeviceUIUtils tt_newPadding:57.f/2])
#define kTTProfileNameContainerLeftMargin  [TTDeviceUIUtils tt_newPadding:28.f/2]

#define kTTProfileCareNumberFontSize (34.f/2)
#define kTTProfileCareNumberColorKey (kColorText10)
#define kTTProfileCareTextFontSize   (24.f/2)
#define kTTProfileCareTextColorKey   (kColorText11)



/**
 * 社交关系详情页标注
 */
#define kTTSocialHubTitleCellHeight  (112.f/2) // title + content
#define kTTSocialHubDetailCellHeight (132.f/2) // title + subTitle (detail)
#define kTTSocialHubImageWidth       (72.f/2 + 2.f/2) // 加外描边

#define kTTSocialHubSpacingOfAvatarTitle   (20.f/2)
#define kTTSocialHubSpacingOfTitleSubtitle (16.f/2)

#define kTTSocialHubTitleFontSize    (34.f/2)
#define kTTSocialHubTitleColorKey    (kColorText1)

#define kTTSocialHubContentFontSize  (28.f/2)
#define kTTSocialHubContentColorKey  (kColorText3)

#define kTTSocialHubSubtitle2FontSize  (24.f/2)
#define kTTSocialHubSubtitle2ColorKey  (kColorText3)

#define kTTSocialHubSubtitle1FontSize  (24.f/2)
#define kTTSocialHubSubtitle1ColorKey  (kColorText1)


#endif /* TTProfileThemeConstants_h */

