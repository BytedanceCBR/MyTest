//
//  TTRepostContentSegment.h
//  Article
//
//  Created by ranny_90 on 2017/9/14.
//
//

#import <Foundation/Foundation.h>
#import "TTRichSpanText.h"

@interface TTRepostContentSegment : NSObject

@property (nonatomic, strong) TTRichSpanText *content;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userSchema;

- (instancetype)initWithRichSpanText:(TTRichSpanText *)richSpanText
                              userID:(NSString *)userID
                            username:(NSString *)username;
- (instancetype)initWithText:(NSString *)text
                      userID:(NSString *)userID
                    username:(NSString *)username;

+ (TTRichSpanText *)richSpanTextForRepostSegments:(NSArray<TTRepostContentSegment *> *)segments;

@end

@interface TTRichSpanText(UserScheme)


/**
 不要加@，方法自己加
 
 @param name 名字 请不要加@，name为空不会处理
 @param schema 可以为空
 */
- (void) appendUserName:(NSString *)name schema:(NSString *)schema;

/**
 不要加@，方法自己加
 
 @param name 名字 请不要加@，name为空不会处理
 @param userID 可以为空
 */
- (void) appendUserName:(NSString *)name userID:(NSString *)userID;
@end

