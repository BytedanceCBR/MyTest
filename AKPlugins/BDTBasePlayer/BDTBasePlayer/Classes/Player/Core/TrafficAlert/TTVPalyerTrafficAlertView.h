//
//  TTVPlayerTrafficAlertView.h
//  Article
//
//  Created by panxiang on 2017/5/23.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
@interface TTVPalyerTrafficAlertView : UIView<TTVPlayerViewTrafficView>
@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@end

