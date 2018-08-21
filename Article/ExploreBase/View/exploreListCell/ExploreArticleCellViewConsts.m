//
//  ExploreArticleCellViewConsts.m
//  Article
//
//  Created by Chen Hong on 14/12/9.
//
//

#import <Foundation/Foundation.h>
#import "ExploreArticleCellViewConsts.h"
#import "NewsUserSettingManager.h"
#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"

/** view上边距(纯文字、大图、多图、视频) */
inline CGFloat cellTopPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 16.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 16.f;
    }
}

/** view上边距(右图、右视频) */
inline CGFloat cellTopPaddingWithRightPic() {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 14.f;
    } else {
        return 16.f;
    }
}

/** view下边距(纯文字) */
inline CGFloat cellBottomPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 16.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 16.f;
    }
}

/** view下边距(右图、右视频、大图、多图、视频) */
inline CGFloat cellBottomPaddingWithPic() {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 14.f;
    } else {
        return 14.f;
    }
}

/** view左边距 */
inline CGFloat cellLeftPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 15.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 15.f;
    } else {
        return 15.f;
    }
}

/** view右边距 */
inline CGFloat cellRightPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 10.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 10.f;
    } else {
        return 15.f;
    }
}

/** titleLabel与infoLabel的间距 */
inline CGFloat cellTitleBottomPaddingToInfo() {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 10.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 10.f;
    } else {
        return 6.f;
    }
}

inline CGFloat cellInfoBarTopPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 8.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 8.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 8.f;
    } else {
        return 6.f;
    }
}

inline CGFloat cellGroupPicTopPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 8.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 8.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 8.f;
    } else {
        return 6.f;
    }
}

/** 类型标签内部间距 */
inline CGFloat cellTypeLabelInnerPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 8.f;
    }
    else {
        return 3.f;
    }
}

inline CGFloat cellUninterestedButtonRightPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 20.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 20.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 20.f;
    } else {
        return 15.f;
    }
}

inline CGFloat cellCommentTopPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 8.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 8.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 8.f;
    } else {
        return 6.f;
    }
}

inline CGFloat cellCommentViewVerticalPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 12.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 12.f;
    } else {
        return 10.f;
    }
}

inline CGFloat cellCommentViewHorizontalPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 12.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 12.f;
    } else {
        return 10.f;
    }
}

inline CGFloat cellEntityWordTopPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 8.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 8.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 8.f;
    } else {
        return 6.f;
    }
}

inline CGFloat cellEntityWordViewVerticalPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 12.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 12.f;
    } else {
        return 10.f;
    }
}

inline CGFloat cellEntityWordViewLeftPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 12.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 12.f;
    } else {
        return 10.f;
    }
}

/** titleLabel行高 */
inline CGFloat cellTitleLineHeight() {
    if ([TTDeviceHelper isPadDevice]) {
        return ceil(cellTitleLabelFontSize() * 25 / 19);
    } else if ([TTDeviceHelper is736Screen]) {
        return ceil(cellTitleLabelFontSize() * 25 / 19);
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return ceil(cellTitleLabelFontSize() * 25 / 19);
    } else {
        return ceil(cellTitleLabelFontSize() * 44 / 34);
    }
}

/** titleLabel字体大小 */
inline CGFloat cellTitleLabelFontSize() {
    CGFloat fontSize;
    if ([TTUISettingHelper cellViewTitleFontSizeControllable]){
        return [TTUISettingHelper cellViewTitleFontSize];
    }
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 20.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 19.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 19.f;
    } else {
        fontSize = 17.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}

/** infoBar高度 */
inline CGFloat cellInfoBarHeight() {
    return 14.f;//ceil(cellInfoLabelFontSize());
}

/** 类型标签字体大小 */
inline CGFloat cellTypeLabelFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 10.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 10.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 10.f;
    } else {
        fontSize = 10.f;
    }
    return fontSize;
}

/** 内容字体大小 */
inline CGFloat cellInfoLabelFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 16.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 12.f;
    } else {
        fontSize = 10.f;
    }
    return fontSize;
}

/** 摘要行高 */
inline CGFloat cellAbstractViewLineHeight() {
    if ([TTDeviceHelper isPadDevice]) {
        return ceil(cellAbstractViewFontSize() * 1.4);
    } else if ([TTDeviceHelper is736Screen]) {
        return ceil(cellAbstractViewFontSize() * 1.4);
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return ceil(cellAbstractViewFontSize() * 1.4);
    } else {
        return ceil(cellAbstractViewFontSize() * 34 / 24);
    }
}

/** 摘要字体大小 */
inline CGFloat cellAbstractViewFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 15.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 15.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 15.f;
    } else {
        fontSize = 12.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}


/** 问答摘要字体大小 */
inline CGFloat cellWenDaAbstractViewFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 14.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 14.f;
    } else {
        fontSize = 12.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}

/** 问答摘要行高 */
inline CGFloat cellWenDaAbstractViewLineHeight() {
    if ([TTDeviceHelper isPadDevice]) {
        return ceil(cellWenDaAbstractViewFontSize() * 1.4);
    } else if ([TTDeviceHelper is736Screen]) {
        return ceil(cellWenDaAbstractViewFontSize() * 1.4);
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return ceil(cellWenDaAbstractViewFontSize() * 1.4);
    } else {
        return ceil(cellWenDaAbstractViewFontSize() * 34 / 24);
    }
}

/** 评论框行高 */
inline CGFloat cellCommentViewLineHeight() {
    if ([TTDeviceHelper isPadDevice]) {
        return ceil(cellAbstractViewFontSize() * 1.4);
    } else if ([TTDeviceHelper is736Screen]) {
        return ceil(cellAbstractViewFontSize() * 1.4);
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return ceil(cellAbstractViewFontSize() * 1.4);
    } else {
        return ceil(cellAbstractViewFontSize() * 34 / 24);
    }
}

/** 评论框字体大小 */
inline CGFloat cellCommentViewFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 15.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 14.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 14.f;
    } else {
        fontSize = 12.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}

/** 实体词高度 */
inline CGFloat cellEntityWordViewHeight() {
    return kCellEntityWordViewFontSize + kCellEntityWordViewVerticalPadding * 2;
}

/** 实体词文字大小 */
inline CGFloat cellEntityWordViewFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 15.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 15.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 15.f;
    } else {
        fontSize = 12.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}

inline CGFloat cellSixteenWordFontSize() {
    
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 16.f;
        return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:YES];
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 16.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 16.f;
    } else {
        fontSize = 13.f;
    }
    return [NewsUserSettingManager fontSizeFromNormalSize:fontSize isWidescreen:NO];
}

inline CGFloat cellGroupPicPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else {
        return 2.f;
    }
}

inline CGFloat channelFontSize() {
    if ([TTDeviceHelper isPadDevice]) {
        return 17.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 17.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 17.f;
    } else {
        return 16.f;
    }
}

inline CGFloat channelSelectedFontSize() {
    if ([TTDeviceHelper isPadDevice]) {
        return 19.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 19.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 19.f;
    } else {
        return 17.f;
    }
}

inline CGFloat cellAbstractViewCorrect() {
    return ceil(cellAbstractViewLineHeight() - cellAbstractViewFontSize());
}

inline CGFloat cellCommentViewCorrect() {
    return ceil(cellCommentViewLineHeight() - cellCommentViewFontSize() - 1);
}

#pragma mark - other

inline CGFloat cellPaddingY() {
    if ([TTDeviceHelper isPadDevice]) {
        return 15.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice] || [TTDeviceHelper is736Screen]) {
        return 10.f;
    } else {
        return 6.f;
    }
}

inline BOOL shouldShowInfoBar(CGFloat cellWidth) {
    if ([TTDeviceHelper isPadDevice]) {
        return cellWidth < 400; // iPad分屏后位于右屏
    }
    else {
        return YES;
    }
}

//inline CGFloat cellTypeLabelFontSize() {
//    if ([TTDeviceHelper isPadDevice]) {
//        return 13.f;
//    }
//    else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen]) {
//        return 10.f;
//    }
//    else {
//        return 9.f;
//    }
//}

inline CGFloat cellTypeLabelW() {
    if ([TTDeviceHelper isPadDevice]) {
        return 24.0f;
    }
    else {
        return 24.f;
    }
}


inline CGFloat cellTypeLabelCornerRadius() {
    if ([TTDeviceHelper isPadDevice]) {
        return 4.;
    }
    else {
        return 2.;
    }
}

inline CGFloat cellTypeLabelRightPadding() {
    if ([TTDeviceHelper isPadDevice]) {
        return 10.;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 5.f;
    }
    else {
        return 4.;
    }
}







inline CGFloat cellRightPicWidth(CGFloat cellWidth) {
    if ([TTDeviceHelper isPadDevice] && cellWidth > 400) {
        return 135.f;
    } else if (cellWidth > 320) {
        return 114.f;
    } else {
        return 95.f;
    }
}

inline CGFloat cellRightPicHeight(CGFloat cellWidth) {
    if ([TTDeviceHelper isPadDevice] && cellWidth > 400) {
        return 90.0f;
    } else if (cellWidth > 320) {
        return 75.f;
    } else {
        return 62.f;
    }
}



inline CGFloat cellRightPicTop() {
    return 16.0f;
}




inline CGFloat cellPureTitleMinHeight1Line() {
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 83.f;
    } else {
        return 72.f;
    }
}

inline CGFloat cellPureTitleMinHeight2Line() {
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 107.f;
    } else {
        return 94.f;
    }
}

inline CGFloat prefferedCellPureTitleHeightWithHeight(CGFloat height) {
    if (height < cellPureTitleMinHeight1Line()) {
        height = cellPureTitleMinHeight1Line();
    } else if (height < cellPureTitleMinHeight2Line()) {
        height = cellPureTitleMinHeight2Line();
    }
    return height;
}

inline CGFloat infoViewFontSize() {
    if ([TTDeviceHelper isPadDevice]) {
        return 11.f;
    } else if ([TTDeviceHelper is736Screen]) {
        return 11.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 11.f;
    } else {
        return 10.f;
    }
}
