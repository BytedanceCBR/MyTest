//
//  TTLiveWebViewVC.h
//  TTLive
//
//  Created by matrixzk on 4/18/16.
//
//

#import <UIKit/UIKit.h>

@class TTLiveMainViewController;

@interface TTLiveWebViewVC : UIViewController

- (instancetype)initWithDataSourceModel:(id)model chatroom:(TTLiveMainViewController *)chatroom;

@end
