//
//  NSObject+MultiDelegates.h
//  Article
//
//  Created by yuxin on 3/3/16.
//
//

#import <Foundation/Foundation.h>

/* 
    注意：重新设置delegate时有bug
 
    scrollView.delegate = self;
    [scrollView tt_addDelegate:foo];
    ...
    scrollView.delegate = self;
*/

@class TTProxyDelegate;

@interface NSObject (MultiDelegates)

@property (nonatomic, strong) TTProxyDelegate * ttProxyDelegate;

-(BOOL)tt_addDelegate:(id)delegate asMainDelegate:(BOOL)asMain;

-(BOOL)tt_removeDelegate:(id)deldegate;

-(void)tt_removeAllDelegates;

@end


 