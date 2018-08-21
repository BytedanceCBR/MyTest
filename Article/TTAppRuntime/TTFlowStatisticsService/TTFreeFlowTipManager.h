//
//  TTFreeFlowTipManager.h
//  Article
//
//  Created by wangdi on 2017/7/7.
//
//

#import <Foundation/Foundation.h>

@interface TTFreeFlowTipManager : NSObject

+ (instancetype)sharedInstance;

- (void)showHomeFlowAlert;

- (BOOL)shouldShowPullRefreshTip;

@end
