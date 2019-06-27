//
//  SSWeakObject.h
//  Article
//
//  Created by Dianwei on 14-11-1.
//
//

#import <UIKit/UIKit.h>

@interface SSWeakObject : NSObject
+ (instancetype)weakObjectWithContent:(NSObject *)content;
- (instancetype)initWithContent:(NSObject *)content;
@property (nonatomic, weak) NSObject *content;

@end
