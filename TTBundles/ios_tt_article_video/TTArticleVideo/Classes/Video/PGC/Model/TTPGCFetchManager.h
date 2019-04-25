//
//  TTPGCFetchManager.h
//  Article
//
//  Created by 刘廷勇 on 15/11/4.
//
//

#import <Foundation/Foundation.h>
#import "TTVideoPGCViewModel.h"

extern NSString *kVideoPGCStatusChangedNotification;

typedef void(^TTPGCCompletion)(TTVideoPGCViewModel *model, NSError *error);

@interface TTPGCFetchManager : NSObject

- (void)startFetchWithCompletion:(TTPGCCompletion)completion;

+ (BOOL)shouldShowVideoPGC;

+ (void)setShouldShowVideoPGC:(BOOL)show;

@end
