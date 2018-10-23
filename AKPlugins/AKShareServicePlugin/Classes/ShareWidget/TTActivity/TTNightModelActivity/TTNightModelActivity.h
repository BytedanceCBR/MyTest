//
//  TTNightModelActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTNightModelContentItem.h"

@interface TTNightModelActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTNightModelContentItem *contentItem;
@property (nonatomic, weak) UIViewController *presentingViewController;

@end
