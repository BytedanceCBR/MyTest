//
//  ResurfaceData.m
//  Article
//
//  Created by chenjiesheng on 2017/7/8.
//
//

#import "ResurfaceData.h"

@implementation ResurfaceData

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[@"uniqueID",
                       @"content",
                       @"imageURL",
                       @"openURL"
                       ];
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    [super updateWithDictionary:dictionary];
    NSString *imageURL = [dictionary tt_stringValueForKey:@"image_url"];
    if (!isEmptyString(imageURL)){
        self.imageURL = imageURL;
    }else{
        self.imageURL = @"http://p3.pstatp.com/origin/dcd000ec4dd003f46cb";
    }
    if ([dictionary objectForKey:@"desc"]){
        self.content = [dictionary tt_stringValueForKey:@"content"];
    }else{
        self.content = @"尝试下全新的爱看界面吧!";
    }
    if ([dictionary objectForKey:@"open_url"]){
        self.openURL = [dictionary tt_stringValueForKey:@"open_url"];
    }else{
        self.openURL = @"sslocal://resurface";
    }
}
@end
