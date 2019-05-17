//
//  TTFantasyWindowManager.h
//  Article
//
//  Created by chenren on 2018/01/17.
//

#import <Foundation/Foundation.h>
#import "TTFDashboardViewController.h"
#import "TTFQuizShowLiveRoomViewController.h"
#import "TTFTalkBoardViewController.h"
#import "TTAccountAlertView.h"

@interface TTFDashboardViewController (TT_Close)

@end

@interface TTFQuizShowLiveRoomViewController (TT_Close)

@end

@interface TTUIResponderHelper (TT_Login)

@end

@interface TTAccountAlertView (TT_Login)

@end

@interface TTFTalkBoardViewController (TT_Login)

@end

@interface TTFantasyWindow : UIWindow

@end

@interface TTFantasyWindowManager : NSObject

+ (instancetype)sharedManager;
- (void)show;
- (void)dismiss;
- (void)changeWindowSize;
- (void)closeFantasyWindow;

@property (nonatomic, strong) TTFantasyWindow *fantasyWindow;
@property (nonatomic, strong) UIWindow *parentKeyWindow;
@property (nonatomic, assign) BOOL isSmallMode;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, strong) NSDictionary *trackerDescriptor;

@end
