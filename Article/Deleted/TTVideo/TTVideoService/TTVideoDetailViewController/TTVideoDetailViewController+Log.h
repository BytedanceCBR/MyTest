//
//  TTVideoDetailViewController+Log.h
//  Article
//
//  Created by 刘廷勇 on 16/4/26.
//
//

#import "TTVideoDetailViewController.h"

@interface TTVideoDetailViewController (Log)

- (void)logEnter;

- (void)logReadPctTrack;

- (void)logClickReport;

- (void)logClickWriteComment;

- (void)logConfirmComment;

- (void)logClickComment:(VideoDetailViewShowStatus)status;

- (void)logFavorite;

- (void)logUnFavorite;

- (void)sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra click:(BOOL)click;

@end
