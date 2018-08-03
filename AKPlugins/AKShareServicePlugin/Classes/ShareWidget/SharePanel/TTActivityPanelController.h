//
//  TTActivityPanelController.h
//  Article
//
//  Created by zhaopengwei on 15/7/26.
//
//

#import <Foundation/Foundation.h>
#import <TTShare/TTActivityPanelControllerProtocol.h>

@interface TTActivityPanelController : NSObject<TTActivityPanelControllerProtocol>

@property (nonatomic, weak) id<TTActivityPanelDelegate> delegate;

@end
