//
//  M3U8Parser.m
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "M3U8Parser.h"
#import "VideoDataUtil.h"
#import "NSStringAdditions.h"

@implementation M3U8Segment
@synthesize duration, localUrlString, originalURLString, localPath;
- (void)dealloc
{
    self.localUrlString = nil;
    self.originalURLString = nil;
    self.localPath = nil;
    [super dealloc];
}

- (NSDictionary*)dictionaryPresentation
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:4];
    [mDict setValue:[NSNumber numberWithInt:duration] forKey:@"length"];
    [mDict setValue:originalURLString forKey:@"original_url"];
    [mDict setValue:localUrlString forKey:@"local_url"];
    [mDict setValue:localPath forKey:@"local_path"];
    return mDict;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"duration:%d, ori url:%@, local url:%@, local path:%@", duration, originalURLString, localUrlString, localPath];
}



@end

@interface M3U8Parser()
@property(nonatomic, retain, readwrite)NSString *localContent;
@property(nonatomic, retain, readwrite)NSError *error;
@property(nonatomic, retain, readwrite)NSMutableArray *_segments;
@property(nonatomic, retain, readwrite)NSMutableDictionary *_metaData;
@property(nonatomic, retain)VideoData *video;
@end

@implementation M3U8Parser
@synthesize _metaData, _segments, error, localContent, video;
- (void)dealloc
{
    self.localContent = nil;
    self.error = nil;
    self._segments = nil;
    self._metaData = nil;
    self.video = nil;
    [super dealloc];
}

- (id)initWithVideo:(VideoData*)tVideo
{
    self = [super init];
    if(self)
    {
        self._segments = [[[NSMutableArray alloc] init] autorelease];
        self._metaData = [[[NSMutableDictionary alloc] init] autorelease];
        self.video = tVideo;
    }
    
    return self;
}

- (NSArray*)segments
{
    return [NSArray arrayWithArray:_segments];
}

- (NSDictionary*)metaData
{
    return [NSDictionary dictionaryWithDictionary:_metaData];
}

- (void)parse:(NSString*)content sourceURL:(NSURL*)sourceURL
{
    NSMutableString *str = [NSMutableString stringWithCapacity:content.length];
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *line = (NSString*)obj;
        if(!isEmptyString(line))
        {
            NSString *parsedLine = [self processLine:obj lineNumber:idx sourceURL:(NSURL*)sourceURL];
            [str appendFormat:@"%@\n", parsedLine];
        }
    }];
    
    self.localContent = str;
}

- (NSString*)processLine:(NSString*)line lineNumber:(int)lineNumber sourceURL:(NSURL*)sourceURL
{
    NSString *result = nil;
    if([line rangeOfString:@"#EXTINF" options:NSCaseInsensitiveSearch].location != NSNotFound) // according to specification, each segement URI should be proceeded by EXTINF
    {
        if([_segments lastObject] && ! ((M3U8Segment*)[_segments lastObject]).originalURLString)
        {
            NSString *reason = [NSString stringWithFormat:@"Didn't find URI for the provious one and encounters another at line:%d", lineNumber];
            self.error = [NSError errorWithDomain:kM3U8ErrorDomain 
                                             code:kM3U8FileFormatErrorCode 
                                         userInfo:[NSDictionary dictionaryWithObject:reason forKey:@"reason"]];
        }
        
        else
        {
            NSRegularExpression *expression = [NSRegularExpression  regularExpressionWithPattern:@"#EXTINF:(.*)," options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult *match = [expression firstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
            if(match.range.location == NSNotFound)
            {
                NSString *reason = [NSString stringWithFormat:@"EXTINF format error at line:%d", lineNumber];
                self.error = [NSError errorWithDomain:kM3U8ErrorDomain 
                                                 code:kM3U8FileFormatErrorCode 
                                             userInfo:[NSDictionary dictionaryWithObject:reason forKey:@"reason"]];
            }
            else
            {
                M3U8Segment *segment = [[M3U8Segment alloc] init];
                segment.duration = [[line substringWithRange:[match rangeAtIndex:1]] intValue];                
                [_segments addObject:segment];
                [segment release];
                result = line;
            }
        }
    }
    else if([line rangeOfString:@"#EXT-X-VERSION" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSArray *components = [line componentsSeparatedByString:@":"];
        if([components count] > 1)
        {
            [self._metaData setObject:[components objectAtIndex:1] forKey:kM3U8SegmentVersionKey];
        }
        
        result = line;
    }
    else if([line rangeOfString:@"#" options:NSLiteralSearch range:NSMakeRange(0, 1)].location == NSNotFound)
    {
        NSURL *url = [NSURL URLWithString:line];
        if(url) // it's a valid url
        {
            M3U8Segment *lastSegment = [_segments lastObject];
            if(!lastSegment || lastSegment.originalURLString)
            {
                NSString *reason = [NSString stringWithFormat:@"Encouter an URI without processing matching duration at line:%ds", lineNumber];
                self.error = [NSError errorWithDomain:kM3U8ErrorDomain 
                                                 code:kM3U8FileFormatErrorCode 
                                             userInfo:[NSDictionary dictionaryWithObject:reason forKey:@"reason"]];
            }
            else 
            {
                if(url.host == nil) // it's a relative path
                {
                    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", sourceURL.scheme, sourceURL.host]];
                    NSURL *originalURL = [[NSURL URLWithString:line relativeToURL:baseURL] absoluteURL];
                    lastSegment.originalURLString = [originalURL absoluteString];
                    lastSegment.localPath = [self segmentLocalPathForURL:originalURL];
                    lastSegment.localUrlString = [self segmentLocalURLStringForURL:originalURL];
                }
                else 
                {
                    lastSegment.originalURLString = line;
                    lastSegment.localPath = [self segmentLocalPathForURL:url];
                    lastSegment.localUrlString = [self segmentLocalURLStringForURL:url];    
                }
                
                result = lastSegment.localUrlString;
            }
        }
        else {
            result = line;
        }
        
    }
    else {
        result = line;
    }
    
    return result;
}

- (void)clearResult
{
    self.localContent = nil;
    self.error = nil;
    [_segments removeAllObjects];
    [_metaData removeAllObjects];
}


- (NSString*)segmentLocalPathForURL:(NSURL*)url
{
    NSString *md5 = [url.absoluteString MD5HashString];
    return [[VideoDataUtil localBasePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%d/%@", [video.groupID intValue], md5]];
}

- (NSString*)segmentLocalURLStringForURL:(NSURL*)url
{
    NSString *md5 = [url.absoluteString MD5HashString];
    return [[VideoDataUtil localBaseURLString] stringByAppendingString:[NSString stringWithFormat:@"/%d/%@", [video.groupID intValue], md5]];
}

@end
