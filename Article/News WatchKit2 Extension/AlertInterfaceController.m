//
//  AlertInterfaceController.m
//  Article
//
//  Created by yuxin on 5/29/15.
//
//

#import "AlertInterfaceController.h"

@interface AlertInterfaceController ()

@end

@implementation AlertInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
- (IBAction)closeAlert:(id)sender {
    [self dismissController];
}
@end



