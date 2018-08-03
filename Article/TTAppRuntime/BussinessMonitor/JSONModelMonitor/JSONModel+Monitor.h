//
//  JSONModel+Monitor.h
//  Article
//
//  Created by lizhuoli on 16/12/14.
//
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

/** Currently, we just swizzle JSONModel to protect throws NSException and monitor
 For user, you do not need to use @try @catch when init with JSON compared to original JSONModel
 For further usage, we can create JSONModel subclass JSONModel and use @try @catch to protect.
 Then create JSONModel+Monitor swizzle to monitor both exception and error
 */


/**
 * If JSONModel internal throw an exception(which catched by JSONModel+Monitor), check the
 * userInfo dictionary of the NSError(or JSONModelError) instance you get back -
 * under the kJSONModelTypeMismatch key you will find the NSException object
 */
extern NSString * const kJSONModelException;

