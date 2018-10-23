//
//  SSBaseModel.m
//  Article
//
//  Created by Dianwei on 14-5-23.
//
//

#import "SSBaseModel.h"

@interface SSBaseModel()

@end

@implementation SSBaseModel

//- (NSUInteger)hash
//{
//    return [self.ID hash];
//}

- (BOOL)isEqual:(id)object
{
    if(object == self)
    {
        return YES;
    
    }
    
    if([object isKindOfClass:[self class]])
    {
        return [self.ID isEqualToString:[object valueForKey:@"ID"]];
    }
    
    return NO;
    
}

@end
