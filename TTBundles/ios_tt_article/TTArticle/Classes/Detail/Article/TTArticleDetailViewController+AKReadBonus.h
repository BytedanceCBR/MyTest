//
//  TTArticleDetailViewController+AKReadBonus.h
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#import "TTArticleDetailViewController.h"

@interface TTArticleDetailViewController (AKReadBonus)

- (void)ak_createCountDownTimer;
- (void)ak_resumeCountDownTimer;
- (void)ak_suspendCountDownTimer;
- (void)ak_readComplete;
- (void)ak_checkNeedReadBonus;
@end
