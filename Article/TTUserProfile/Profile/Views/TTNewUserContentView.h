//
//  TTNewUserContentView.h
//  Article
//
//  Created by it-test on 8/8/16.
//
//

#import "SSThemed.h"

@interface TTNewUserContentView : SSThemedView

/**
 * refresh user all information included profile and visited history
 */
- (void)refreshUserInfo;

/**
 * only refresh user's history visited information
 */
- (void)refreshUserVisitedHistoryInfo;
@end
