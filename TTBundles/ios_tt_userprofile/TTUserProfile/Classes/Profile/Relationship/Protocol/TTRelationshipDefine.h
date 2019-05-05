//
//  TTRelationshipDefine.h
//  Article
//
//  Created by lizhuoli on 2017/8/3.
//
//

#ifndef TTRelationshipDefine_h
#define TTRelationshipDefine_h

#define RelationViewHasGetSuggestFriendCountNotification @"RelationViewHasGetSuggestFriendCountNotification"
#define kRelationViewHasGetSuggestFriendCountNotificationCountKey @"kRelationViewHasGetSuggestFriendCountNotificationCountKey"
#define kRelationViewHasShowUserNameTipUserDefaultKey @"kRelationViewHasShowUserNameTipUserDefaultKey"
#define kRelationViewSuggestUserViewShowedNotification @"kRelationViewSuggestUserViewShowedNotification"

typedef enum {
    RelationViewAppearTypePGCLikeUser = 0,
    RelationViewAppearFollowing       = 1,
    RelationViewAppearTypeFollower    = 2,
    RelationViewAppearTypeVisitor     = 3,
    
} RelationViewAppearType;

#endif /* TTRelationshipDefine_h */
