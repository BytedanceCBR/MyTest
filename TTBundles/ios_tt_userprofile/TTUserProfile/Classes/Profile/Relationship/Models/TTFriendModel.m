//
//  TTFriendModel.m
//  Article
//
//  Created by it-test on 8/22/16.
//
//

#import "TTFriendModel.h"
#import <TTAccountBusiness.h>
#import <objc/runtime.h>


@implementation TTFriendModel
- (BOOL)isAccountUserOfVisitor {
    return ([self.visitorUID isEqualToString:[TTAccountManager userID]] ||
            [self.visitorUID isEqualToString:@"0"]);
}

- (NSString *)description {
    NSString *despString = [NSString stringWithFormat:@"<%@: %p: ", NSStringFromClass(self.class), self];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (uint i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        if (name) {
            if (i != 0) {
                despString = [despString stringByAppendingFormat:@", %@=%@", name, [self valueForKey:name]];
            } else {
                despString = [despString stringByAppendingFormat:@"%@=%@", name, [self valueForKey:name]];
            }
        }
    }
    free(properties);
    despString = [despString stringByAppendingFormat:@">"];
    
    return despString;
}
@end
