//
//  TSVStartupTabManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/10/29.
//

#import <Foundation/Foundation.h>

@interface TSVStartupTabManager : NSObject

@property (nonatomic, assign) BOOL shortVideoTabViewControllerVisibility;

@property (nonatomic, assign) BOOL detailViewControllerVisibility;

@property (nonatomic, assign) BOOL inShortVideoTabViewController;

+ (instancetype)sharedManager;

- (BOOL)shouldEnterShortVideoTabWhenStartup;

@end
