//
//  TTPostCheckBindPhoneViewModel.h
//  Article
//
//  Created by ranny_90 on 2017/8/8.
//
//

#import <Foundation/Foundation.h>
#import "FRApiModel.h"

@interface TTPostCheckBindPhoneViewModel : NSObject

+ (void)checkPostNeedBindPhoneOrNotWithCompletion:(void(^ _Nullable)(FRPostBindCheckType checkType))completion;

@end
