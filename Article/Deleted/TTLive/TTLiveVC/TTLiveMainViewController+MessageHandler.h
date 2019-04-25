//
//  TTLiveMainViewController+MessageHandler.h
//  Article
//
//  Created by matrixzk on 8/1/16.
//
//

#import "TTLiveMainViewController.h"

@interface TTLiveMainViewController ()
@property (nonatomic, strong) NSMutableArray *msgSenderArray;
@end


@interface TTLiveMainViewController (MessageHandler) <TTLiveMessageBoxDelegate, TTLiveMessageHandleDelegate>

@end
