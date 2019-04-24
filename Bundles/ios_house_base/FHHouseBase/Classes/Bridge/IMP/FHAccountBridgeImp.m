//
//  FHAccountBridgeImp.m
//  Article
//
//  Created by 春晖 on 2019/4/11.
//

#import "FHAccountBridgeImp.h"
#import "TTAccountLoggerImp.h"

@implementation FHAccountBridgeImp

-(id<TTAccountAuthLoginLogger>)accountLoggerImp
{
    return [TTAccountLoggerImp new];
}

@end
