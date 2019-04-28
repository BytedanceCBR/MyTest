//
//  ArticleAddressManager.h
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import <Foundation/Foundation.h>
#import "SSAddressBook.h"

@interface ArticleAddressManager : NSObject
+ (instancetype)sharedManager;
+ (void)setUploadInterval:(NSTimeInterval)uploadInterval;
+ (NSTimeInterval)uploadInterval;
+ (NSArray*)replaceRegluarExpress;
+ (void)setReplaceRegularExpress:(NSArray*)regex;

- (void)startUploadAddressBookWithPermissionBlock:(void(^)(NSError * error)) permissionBlock uploadFinishBlock:(void(^)(NSError *error))finishBlock;
- (NSString*)processPhoneNumber:(NSString*)phoneNumberString;

@property (nonatomic, readonly) NSDictionary * addressBookPersons;
@end

extern NSString * const ArticleAddressPersonCacheKey;
extern NSString * const kAddressBookHasGotNotification;
