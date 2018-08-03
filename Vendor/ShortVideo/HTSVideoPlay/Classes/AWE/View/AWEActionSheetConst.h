//
//  TTActionSheetConst.h
//  Article
//
//  Created by zhaoqin on 8/28/16.
//
//

#ifndef AWEActionSheetConst_h
#define AWEActionSheetConst_h

#define AWEActionSheetAnimationDuration 0.25f
#define AWEActionSheetFinishedButtonHeight 48
#define AWEActionSheetNavigationBarHeight 54
#define AWEActionSheetTableCellHeight 44

#define AWEActionSheetTableCellIdentifier @"AWEActionSheetTableCellIdentifier"
#define AWEActionSheetWriteCommentCellIdentifier @"AWEActionSheetWriteCommentCellIdentifier"
#define AWEActionSheetTableHeight (self.model.itemArray.count + 1) * AWEActionSheetTableCellHeight
#define AWEActionSheetFinishedClickNotification @"AWEActionSheetFinishedClickNotification"

typedef NS_ENUM(NSUInteger, AWEActionSheetTransitionType) {
    AWEActionSheetTransitionTypePresent,
    AWEActionSheetTransitionTypeDismiss,
};
#endif
