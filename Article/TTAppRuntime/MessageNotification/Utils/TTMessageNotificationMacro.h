//
//  TTMessageNotificationMacro.h
//  Article
//
//  Created by lizhuoli on 17/3/27.
//
//

#ifndef TTMessageNotificationMacro_h
#define TTMessageNotificationMacro_h

#define kTTMessageNotificationErrorDomain @"kTTMessageNotificationErrorDomain"
#define kTTMessageNotificationAllChannel @"all"
#define kTTMessageNotificationScheme @"sslocal://message"
#define kTTMessageNotificationTrackExtra(value) value ? @{@"action_type":value} : nil

#define kTTMessageWDInviteAnswerNotInterestNotification @"kTTMessageWDInviteAnswerNotInterestNotification"
#define kTTMessageWDInviteAnswerNotInterestWordsKey  @"kTTMessageWDInviteAnswerNotInterestWordsKey"
#define kTTMessageWDDislikeDataKey  @"kTTMessageWDDislikeDataKey"

#endif /* TTMessageNotificationMacro_h */
