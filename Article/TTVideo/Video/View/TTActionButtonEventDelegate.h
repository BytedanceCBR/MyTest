//
//  TTActionButtonEventDelegate.h
//  Article
//
//  Created by Dai Dongpeng on 7/27/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  使用ArticleVideoActionButton时容易发生循环引用，暂时用这个类来避免，后续可修改ArticleVideoActionButton
 */
@protocol TTActionButtonEventProtocol <NSObject>

- (void)actionButtonPressed:(id)sender;

@end

@interface TTActionButtonEventDelegate : NSObject <TTActionButtonEventProtocol>

- (instancetype)initWithTarget:(id <TTActionButtonEventProtocol>)target;
@property (nonatomic, readonly, weak) id <TTActionButtonEventProtocol> target;

@end


