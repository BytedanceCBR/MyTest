//
//  TTUploadContactsStartupTask.m
//  Article
//
//  Created by Jiyee Sheng on 6/30/17.
//
//

#import "TTUploadContactsStartupTask.h"
#import "TTContactsGuideManager.h"


@implementation TTUploadContactsStartupTask

- (NSString *)taskIdentifier {
    return @"UploadContacts";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTContactsGuideManager autoUploadContactsIfNeeded];
    });
}

@end
