//
//  TTTabBarCustomMiddleModel.h
//  Article
//
//  Created by fengyadong on 2018/1/8.
//

#import <Foundation/Foundation.h>

@interface TTTabBarCustomMiddleModel : NSObject

@property (nonatomic, copy) NSString *originalIdentifier;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *schema;
@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) BOOL useLottieFirst;

@end
