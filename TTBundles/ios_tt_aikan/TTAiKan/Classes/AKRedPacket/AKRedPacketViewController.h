//
//  AKRedPacketViewController.h
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import <UIKit/UIKit.h>
#import <SSViewControllerBase.h>
#import "AKRedpacketEnvBaseView.h"
#import "AKRedPacketDetailBaseView.h"

@interface AKRedPacketViewController : SSViewControllerBase

- (instancetype)initWithViewModel:(AKRedpacketEnvViewModel *)viewModel
                     dismissBlock:(RPDetailDismissBlock)dismissBlock;

@end
