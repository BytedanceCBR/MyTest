//
//  TTPostThreadDefine.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/15.
//
//


#ifndef FR_ForumDefine_h
#define FR_ForumDefine_h

#define DefaultImagesSelectionLimit 9
#define kFRPostMomentDoneNotification @"kFRPostMomentDoneNotification"
#define kFRPostThreadDoneNotification @"kFRPostThreadDoneNotification"
#define kFRPostThreadThaskKey @"kFRPostThreadThaskKey"
#define kFRPostThreadErrorDomain @"kFRPostThreadErrorDomain"
#define kFRPostBaoliaoErrorDomain @"kFRPostBaoliaoErrorDomain"
#define kFRPostForumErrorDomain @"kFRPostForumErrorDomain"

#define kTTPostBehaviorTypePost @"post"
#define kTTPostBehaviorTypeRepost @"repost"


typedef NS_ENUM(NSInteger, TTPostThreadErrorCode)
{
    TTPostThreadErrorCodeNoNetwork = -1,
    TTPostThreadErrorCodeNone = 0,
    TTPostThreadErrorCodeUploadImgError = 1,
    TTPostThreadErrorCodeError = 2,
    TTPostThreadErrorCodeAccountChanged = 3,
    
    TTPostThreadErrorCodeUserCancelled = 4,
    TTPostThreadErrorCodeCannotFindTask = 5,
    TTPostThreadErrorCodeLoginStateValid = 100
};


#endif



