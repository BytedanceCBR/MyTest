//
//  TTActionSheetConst.h
//  Article
//
//  Created by zhaoqin on 8/28/16.
//
//

#ifndef TTActionSheetConst_h
#define TTActionSheetConst_h

#define TTActionSheetFinishedButtonHeight [TTDeviceUIUtils tt_padding:48]
#define TTActionSheetNavigationBarHeight [TTDeviceUIUtils tt_padding:54]

#define TTActionSheetTableCellHeight [TTDeviceUIUtils tt_padding:44]

#define TTActionSheetAnimationDuration 0.25f

#define TTActionSheetTableCellIdentifier @"TTActionSheetTableCellIdentifier"
#define TTActionSheetWriteCommentCellIdentifier @"TTActionSheetWriteCommentCellIdentifier"

#define TTActionSheetTableHeight (self.model.itemArray.count + 1) * TTActionSheetTableCellHeight

#define TTActionSheetFinishedClickNotification @"TTActionSheetFinishedClickNotification"

typedef NS_ENUM(NSInteger, TTActionSheetSourceType) {
    TTActionSheetSourceTypeDislike, //详情页
    TTActionSheetSourceTypeUser, //举报用户
    TTActionSheetSourceTypeWendaQuestion, //问答问题
    TTActionSheetSourceTypeWendaAnswer, //问答回答
    TTActionSheetSourceTypeReport //其他举报
};

typedef NS_ENUM(NSUInteger, TTActionSheetTransitionType) {
    TTActionSheetTransitionTypePresent,
    TTActionSheetTransitionTypeDismiss
};

typedef NS_ENUM(NSInteger, TTActionSheetWebType) {
    TTActionSheetWebTypeDislike = 0x01,
    TTActionSheetWebTypeReport = 0x10,
    TTActionSheetTypeDislikeAndReport = 0x11    
};

#endif /* TTActionSheetConst_h */
