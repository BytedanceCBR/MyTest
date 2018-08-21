//
//  InterfaceController.h
//  News WatchKit Extension
//
//  Created by yuxin on 5/26/15.
//
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (nonatomic,weak) IBOutlet WKInterfaceGroup * articleImage;
@property (nonatomic,weak) IBOutlet WKInterfaceGroup * textBgImage;
@property (nonatomic,weak) IBOutlet WKInterfaceTimer * timerLb;
@property (nonatomic,weak) IBOutlet WKInterfaceLabel * titleLb;
@property (nonatomic,weak) IBOutlet WKInterfaceLabel * commentLb;
@property (nonatomic,weak) IBOutlet WKInterfaceLabel * contentLb;

- (IBAction)openParentApp:(id)sender;

@end
