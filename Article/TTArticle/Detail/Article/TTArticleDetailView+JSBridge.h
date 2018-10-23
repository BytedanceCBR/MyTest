//
//  TTNewDetailWebviewContainer+JSBridge.h
//  Article
//
//  Created by muhuai on 02/03/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTArticleDetailView.h"

@interface TTArticleDetailView (JSBridge)

//注册订阅JSBridge
- (void)registerJSBridge;

@end
