//
//  TTKeyboardListener.h
//  Article
//
//  Created by yuxin on 2/25/16.
//
//

#import <Foundation/Foundation.h>

@interface TTKeyboardListener : NSObject  

@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic, readonly) CGFloat keyboardHeight;

+ (TTKeyboardListener *)sharedInstance;

@end

