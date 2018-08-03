//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "BaseUtillities.h"
#import "../String/NSStringAdditions.h"

NSString * SSLocalizedString(NSString * key, NSString * defaultValue,...) 
{
	// Localize the format
	  
	NSString *localizedStringFormat = [[NSBundle mainBundle] localizedStringForKey:key value:defaultValue table:nil];
	
	va_list args;
    va_start(args, defaultValue);
    NSString *string = [[[NSString alloc] initWithFormat:localizedStringFormat arguments:args] autorelease];
    va_end(args);
	
	return string;
}

NSString * SSStringOrBlank(NSString * value)
{
	return value == nil ? @"" : value;
}

NSString * SSTransNullToBlank(id value)
{
    NSString * tempString = value;
    if ([tempString isEqual:[NSNull null]]){
        tempString = @"";
    }
    
	return tempString;
}

NSError * SSError(NSString * description, ...)
{
	va_list args;
    va_start(args, description);
    NSString *string = [[[NSString alloc] initWithFormat:description arguments:args] autorelease];
    va_end(args);
	
	return [NSError errorWithDomain:@"SSFramework" code:1 userInfo:[NSDictionary dictionaryWithObject:string forKey:NSLocalizedDescriptionKey]];
}

void SSSwizzle(Class c, SEL origSEL, SEL newSEL)
{
	Method origMethod = class_getInstanceMethod(c, origSEL);
	Method newMethod = class_getInstanceMethod(c, newSEL);
	if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
		class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	else
		method_exchangeImplementations(origMethod, newMethod);
}

BOOL SSIsEmptyString(NSString * string)
{
    return ![string isKindOfClass:[NSString class]] || [string length] == 0;
}

NSNumber * SSNumberOrZero(NSNumber * value)
{
    return value == nil ? [NSNumber numberWithInt:0] : value;
}

BOOL SSCheckAndUpdate(NSString * key, int seconds)
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    int lastTime = [defaults integerForKey:key];
    int currentTime = [[NSDate date] timeIntervalSince1970];
    
    if ((lastTime + seconds) <= currentTime) {
        [defaults setInteger:currentTime forKey:key];
        return YES;
    }
    
    return NO;
}

BOOL SSCheckAndUpdateCount(NSString * key, int count, BOOL includeBigger) 
{
    return NO;
}

void setUpCookiesJar(NSString * channelId, NSString * appName)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString * deviceId = [[UIDevice currentDevice]uniqueIdentifier];
    NSString * deviceModel = [[UIDevice currentDevice]model];
    NSString * deviceSystemVersion = [[UIDevice currentDevice]systemVersion];

    [dict setObject:@"uuid" forKey:NSHTTPCookieName];
    [dict setObject:deviceId forKey:NSHTTPCookieValue];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    [dict setObject:@"app_name" forKey:NSHTTPCookieName];
    [dict setObject:appName forKey:NSHTTPCookieValue];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    [dict setObject:@"app_version" forKey:NSHTTPCookieName];
    [dict setObject:[NSString stringOfAppVersion] forKey:NSHTTPCookieValue];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    [dict setObject:@"hardware" forKey:NSHTTPCookieName];
    [dict setObject:deviceModel forKey:NSHTTPCookieValue];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    [dict setObject:@"os_version" forKey:NSHTTPCookieName];
    [dict setObject:deviceSystemVersion  forKey:NSHTTPCookieValue];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    [dict setObject:@"channel" forKey:NSHTTPCookieName];
    if (channelId == nil) {
        [dict setObject:@"appStore" forKey:NSHTTPCookieValue];
    }
    else {
        [dict setObject:channelId  forKey:NSHTTPCookieValue];
    }
    
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    [dict setObject:@"start_time" forKey:NSHTTPCookieName];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    NSString * time = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    [dict setObject:time forKey:NSHTTPCookieValue];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    NSString * keyString = [NSString stringWithFormat:@"%@%@%@",deviceId,appName,[NSString stringOfAppVersion]];
    NSString * dataString = [NSString stringWithFormat:@"%@%@%@",time,deviceModel,deviceSystemVersion];
    NSString * middle =[NSString stringWithFormat:@"%@%@",[keyString MD5HashString],[dataString MD5HashString]];
    NSString * checksum = [middle MD5HashString];
    
    [dict setObject:@"checksum" forKey:NSHTTPCookieName];
    [dict setObject:checksum forKey:NSHTTPCookieValue];
    [dict setObject:@".99fang.com" forKey:NSHTTPCookieDomain];
    [dict setObject:@"/" forKey:NSHTTPCookiePath];
    cookie = [NSHTTPCookie cookieWithProperties:dict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    [pool release];
}


