//
//  LoadMoreInterfaceController.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/21.
//
//

#import "LoadMoreInterfaceController.h"

@implementation LoadMoreInterfaceController

- (void)awakeWithContext:(id)context{
    [super awakeWithContext:context];
    [self setTitle:@"爱看"];
}

- (IBAction)loadMore {
     [WKInterfaceController reloadRootControllersWithNames:@[@"RootInterfaceController"] contexts:nil];
}
@end
