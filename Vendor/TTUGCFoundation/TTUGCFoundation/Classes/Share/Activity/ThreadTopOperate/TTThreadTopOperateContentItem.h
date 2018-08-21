//
//  TTThreadTopOperateContentItem.h
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import <Foundation/Foundation.h>
#import <TTActivityContentItemProtocol.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TTActivityContentItemTypeThreadTopOperate;

@interface TTThreadTopOperateContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy, nullable) TTCustomAction customAction;

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
