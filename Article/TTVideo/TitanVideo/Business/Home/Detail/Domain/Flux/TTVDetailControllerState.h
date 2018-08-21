//
//  TTVDetailControllerState.h
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#ifndef TTVDetailControllerState_h
#define TTVDetailControllerState_h

typedef NS_ENUM(NSUInteger, TTVDetailEventType) {
    TTVDetailEventTypeUnknow = 0,
    //TTVVideoDetailViewController
    TTVDetailEventTypeViewWillAppear = 1,
    TTVDetailEventTypeViewDidAppear = 2,
    TTVDetailEventTypeViewWillDisappear = 3,
    TTVDetailEventTypeViewDidDisappear = 4,
    TTVDetailEventTypeViewDidLoad = 5,
    TTVDetailEventTypeViewWillLayoutSubviews = 6,
    TTVDetailEventTypeCommentDetailViewDidAppear = 7,
    TTVDetailEventTypeCommentDetailViewWillDisappear = 8,
    TTVDetailEventTypeCommentListViewDidAppear = 9,
    TTVDetailEventTypeCommentListViewWillDisappear = 10,
};

#endif /* TTVDetailControllerState_h */
