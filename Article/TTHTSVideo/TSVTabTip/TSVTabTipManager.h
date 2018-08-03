//
//  TSVTabTipManager.h
//  Article
//
//  Created by 邱鑫玥 on 2017/11/7.
//

#import <Foundation/Foundation.h>

@interface TSVTabTipManager : NSObject

+ (instancetype)sharedManager;

- (void)setupShortVideoTabRedDotWhenStartupIfNeeded;

- (BOOL)isShowingRedDot;

- (BOOL)shouldAutoReloadFromRemoteForCategory:(NSString *)categoryID listEntrance:(NSString *)listEntrance;

- (NSDictionary *)extraCategoryListRequestParameters;

- (void)clearRedDot;

- (BOOL)shouldShowBubbleTip;

- (NSString *)textForBubbleTip;

- (NSInteger)indexForBubbleTip;

- (void)updateBubbleTipShownStatus;

- (void)setShouldNotShowBubbleTip;

@end
