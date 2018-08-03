//
//  TTRouteService.h
//  Article
//
//  Created by 冯靖君 on 17/2/24.
//
//

#import <Foundation/Foundation.h>
#import "TTRoute.h"
#import "Singleton.h"

@interface TTRouteService : NSObject <TTRouteLogicDatasource, TTRouteLogicDelegate, TTRouteDesignatedNavProtocol>

+ (void)registerTTRouteService;

@end
