//
//  FRPostThreadDefine.h
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
#define kFRPostForumErrorDomain @"kFRPostForumErrorDomain"

typedef NS_ENUM(NSInteger, FRPostForumErrorCode){
    FRPostForumErrorCodeHasUnUploadImage = 1
};

typedef enum : NSUInteger {
    FRPostMomentSourceFromNotAssign = 0,
    FRPostMomentSourceFromMoment = 1,
    FRPostMomentSourceFromForum = 2,
} FRPostMomentSourceType;

typedef enum : NSUInteger {
    FRForwardForumSourceForward = 1,
} FRForwardForumSourceType;


typedef NS_ENUM(NSInteger, FRPostThreadErrorCode)
{
    FRPostThreadErrorCodeNoNetwork = -1,
    FRPostThreadErrorCodeNone = 0,
    FRPostThreadErrorCodeUploadImgError = 1,
    FRPostThreadErrorCodeError = 2,
    FRPostThreadErrorCodeAccountChanged = 3,
    
    FRPostThreadErrorCodeUserCancelled = 4,
    FRPostThreadErrorCodeCannotFindTask = 5,
    FRPostThreadErrorCodeLoginStateValid = 100
};


#endif



