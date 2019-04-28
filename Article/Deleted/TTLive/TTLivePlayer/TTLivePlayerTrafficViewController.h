//
//  TTLivePlayerTrafficViewController.h
//  Article
//
//  Created by matrixzk on 26/10/2017.
//

#import <Foundation/Foundation.h>

@interface TTLivePlayerTrafficViewController : NSObject

@property (nonatomic, copy) void (^willDisplayTrafficViewBlock)(void);
@property (nonatomic, copy) void (^didEndDisplayingTrafficViewBlock)(void);
@property (nonatomic, readonly) BOOL isShowingTrafficView;
@property (nonatomic, strong, readonly) UIView *trafficView;

- (void)showTrafficViewIfNeeded;
+ (void)changeFrequencyOfTrafficViewDisplayed;

@end
