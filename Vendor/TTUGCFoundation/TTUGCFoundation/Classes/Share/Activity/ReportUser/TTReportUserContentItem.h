//
//  TTReportUserContentItem.h
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import <Foundation/Foundation.h>
#import <TTActivityContentItemProtocol.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TTActivityContentItemTypeReportUser;

@interface TTReportUserContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, copy, nullable) TTCustomAction customAction;

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
