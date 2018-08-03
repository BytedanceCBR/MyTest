//
//  SSIntroduceViewController.h
//  Article
//
//  Created by Dianwei on 13-1-28.
//
//

#import <UIKit/UIKit.h>
#import "NewAuthorityView.h"
#import "ArticleMobileViewController.h"
#import "TTGuideDispatchManager.h"

@interface SSIntroduceViewController : UIViewController <TTGuideProtocol>
@property (nonatomic, strong) NewAuthorityView *authorityView;

@property (nonatomic, strong) ArticleMobilePiplineCompletion  completion;
@end
