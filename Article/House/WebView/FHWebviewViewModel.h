//
//  FHWebviewViewModel.h
//  Article
//
//  Created by 张元科 on 2018/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TTRStaticPlugin;
@class FHWebviewViewController;

@interface FHWebviewViewModel : NSObject

-(instancetype)initWithViewController:(FHWebviewViewController *)viewController;
-(void)registerJSBridge:(TTRStaticPlugin *)plugin;

@end

NS_ASSUME_NONNULL_END
