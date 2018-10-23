//
//  TTQutoedCommentModel.h
//  Article
//
//  Created by muhuai on 16/8/22.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface TTQutoedCommentModel: JSONModel
@property (nonatomic, copy) NSString *commentID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *commentContent;
@property (nonatomic, copy) NSString *commentContentRichSpanJSONString;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
@end
