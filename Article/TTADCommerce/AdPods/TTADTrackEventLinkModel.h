//
//  TTADTrackEventLinkModel.h
//  Article
//
//  Created by ranny_90 on 2017/5/19.
//
//

#import <Foundation/Foundation.h>

@interface TTADTrackEventLinkModel : NSObject

@property (nonatomic,copy) NSString *logExtra;

@property (nonatomic,copy) NSString *adID;

-(NSDictionary *)adEventLinkDictionaryWithTag:(NSString *)tag WithLabel:(NSString *)label;

-(NSString *)adEventLinkJsonStringWithTag:(NSString *)tag WithLabel:(NSString *)label;


-(NSString *)webPageEventLinkExtraData;

@end
