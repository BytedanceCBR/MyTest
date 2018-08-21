//
//  EssayDetailViewController.h
//  Article
//
//  Created by Hua Cao on 13-10-21.
//
//

#import "SSViewControllerBase.h"
#import "EssayData.h"

@interface EssayDetailViewController : SSViewControllerBase

- (EssayDetailViewController *)initWithEssayData:(EssayData *)essayData
                                 scrollToComment:(BOOL)scrollToComment
                                      trackEvent:(NSString *)trackEvent
                                      trackLabel:(NSString *)trackLabel;

@end
