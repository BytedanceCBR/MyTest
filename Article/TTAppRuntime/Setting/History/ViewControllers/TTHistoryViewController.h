//
//  TTHistoryViewController.h
//  Article
//
//  Created by fengyadong on 16/11/22.
//
//

#import "SSViewControllerBase.h"
#import "TTFeedFavoriteHistoryHeader.h"

@interface TTHistoryViewController : SSViewControllerBase <TTFeedFavoriteHistoryProtocol>

@property (nonatomic, assign, readonly) TTHistoryType historyType;

- (instancetype)initWithHistoryType:(TTHistoryType)type;

@end
