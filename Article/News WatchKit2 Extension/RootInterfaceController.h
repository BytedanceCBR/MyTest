//
//  RootInterfaceController.h
//  Article
//
//  Created by yuxin on 5/26/15.
//
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface RootInterfaceController : WKInterfaceController

@property (nonatomic,weak) IBOutlet WKInterfaceButton * retryBtn;
@property (nonatomic,weak) IBOutlet WKInterfaceLabel * statusLb;

@end
