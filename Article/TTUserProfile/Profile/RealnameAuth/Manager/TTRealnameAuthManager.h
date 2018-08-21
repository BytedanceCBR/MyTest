//
//  TTRealnameAuthManager.h
//  Article
//
//  Created by lizhuoli on 16/12/22.
//
//

#import <Foundation/Foundation.h>
#import "TTRealnameAuthResponseModel.h"
#import "TTRealnameAuthMacro.h"

typedef NS_ENUM(NSInteger, TTRealnameAuthImageType) {
    TTRealnameAuthImageCardForeground = 1,
    TTRealnameAuthImageCardBackground = 2,
    TTRealnameAuthImagePerson = 3,
};

typedef void(^uploadBlock)(NSError *, TTRealnameAuthUploadResponseModel *);
typedef void(^statusBlock)(NSError *, TTRealnameAuthStatusResponseModel *);

@interface TTRealnameAuthManager : NSObject

+ (instancetype)sharedInstance;

- (void)uploadImageWithImage:(UIImage *)image type:(TTRealnameAuthImageType)type callback:(uploadBlock)callback;
- (void)submitInfoWithName:(NSString *)name IDNum:(NSString *)IDNum callback:(void (^)(NSError *))callback;
- (void)fetchInfoStatusWithCallback:(statusBlock)callback;

@end
