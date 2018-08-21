//
//  SSFeedbackModel.h
//  Article
//
//  Created by Zhang Leonardo on 13-1-7.
//
//

#import <Foundation/Foundation.h>

#define feedbackTypeUser 0
#define feedbackTypeServer 1

@protocol SSFeedbackModel
@end

@interface SSFeedbackModel : JSONModel

@property(nonatomic, copy)NSString * pubDate;
@property(nonatomic, copy)NSString * content;
@property(nonatomic, copy)NSNumber<Optional> * feedbackType;
@property(nonatomic, copy)NSString<Optional> * imageURLStr;
@property(nonatomic, copy)NSString<Optional> * avatarURLStr;
@property(nonatomic, copy)NSString<Optional> * feedbackID;
@property(nonatomic, copy)NSNumber<Optional> * imageHeight;
@property(nonatomic, copy)NSNumber<Optional> * imageWidth;
@property(nonatomic, copy)NSArray<Optional> * links;
@end

@interface SSFeedbackResponse : JSONModel

@property (nonatomic, copy) NSArray<SSFeedbackModel> *data;
@property (nonatomic, copy) SSFeedbackModel *defaultItem;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSNumber<Optional> *hasMore;

@end
