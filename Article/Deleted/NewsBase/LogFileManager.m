//
//  LogFileManager.m
//  Article
//
//  Created by Dianwei on 13-1-9.
//
//

#import "LogFileManager.h"
#import "NSDateAdditions.h"
#import "NetworkUtilities.h"
#import "ASIFormDataRequest.h"

@interface LogFileManager()

@end

@implementation LogFileManager
static LogFileManager *s_manager;
+ (id)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[LogFileManager alloc] init];
    });
    
    return s_manager;
}

+ (NSString*)destinationPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    NSString *result = [docDirectory stringByAppendingPathComponent:@"/log"];
    return result;
}


- (void)dealloc
{
	[super dealloc];
}

- (void)appendContent:(NSString*)content
{
    NSError *error = nil;
    NSMutableString *oldString = [NSMutableString stringWithContentsOfFile:[LogFileManager destinationPath] encoding:NSUTF8StringEncoding error:&error];
    
    NSString *timeString = [SSCommon dateStringSince:[[NSDate date] timeIntervalSince1970]];
    NSString *connectionType = @"";
    
    if(SSNetworkWifiConnected())
    {
        connectionType = @"wifi";
    }
    else if(SSNetworkConnected())
    {
        connectionType = @"2G/3G";
    }
    else
    {
        connectionType = @"not connected";
    }
    
    
    [oldString appendFormat:@"\n%20@ %20@  %@", timeString, connectionType, content];
    [oldString writeToFile:[LogFileManager destinationPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (NSString*)contents
{
    return [NSString stringWithContentsOfFile:[LogFileManager destinationPath] encoding:NSUTF8StringEncoding error:nil];
}

- (id)init
{
	self = [super init];
	if(self)
	{
        if(![[NSFileManager defaultManager] fileExistsAtPath:[LogFileManager destinationPath]])
        {
            [[NSFileManager defaultManager] createFileAtPath:[LogFileManager destinationPath] contents:nil attributes:nil];
        }
	}
	
	return self;
}

- (void)startTestWithURLConnection:(NSURL*)url get:(NSDictionary*)get post:(NSDictionary*)post
{
    NSURLConnection *connection = [[NSURLConnection alloc] i]
}

- (void)startTestWithASIRequest:(NSURL*)url get:(NSDictionary*)get post:(NSDictionary*)post
{
}

- (void)startSend
{
    NSString *content = [self contents];
    if(!isEmptyString(content))
    {
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:nil];
        [request setPostValue:[SSCommon getUniqueIdentifier] forKey:@"uuid"];
        [request setPostValue:content forKey:@"log"];
    }
}



@end
