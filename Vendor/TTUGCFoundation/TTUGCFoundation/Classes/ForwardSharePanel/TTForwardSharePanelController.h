//
//  TTForwardSharePanelController.h
//  TTShareService
//
//  Created by jinqiushi on 2018/1/17.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "SSThemed.h"


#import <TTShare/TTActivityProtocol.h>
#import <TTShare/TTActivityContentItemProtocol.h>
#import <TTShare/TTActivityPanelControllerProtocol.h>


@interface TTForwardSharePanelWindow : UIWindow
@end


@interface TTForwardSharePanelController : NSObject<TTActivityPanelControllerProtocol>

@property (nonatomic, strong, readonly) TTForwardSharePanelWindow *backWindow;

- (instancetype)initWithItems:(NSArray <NSArray *> *)items cancelTitle:(NSString *)cancelTitle;

- (void)hide;
- (void)show;

@property (nonatomic, weak) id<TTActivityPanelDelegate> delegate;

@end

@class TTRepostThreadSchemaQuoteView;


