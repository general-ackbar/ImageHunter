//
//  GoogleSearcher.m
//  Image Hunter
//
//  Created by Jonatan Yde on 18/03/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "GoogleSearcher.h"
#import "ImageInfo.h"
#import "HttpOperations.h"

@implementation GoogleSearcher




//+(void)PerformSearchUsingQuery:(NSString *)query fromIndex:(int) start completionBlock:(void (^)(NSArray *links))completionBlock
/*
+ (NSArray *)PerformSearchUsingQuery:(NSString *)query fromIndex:(int)start
{
    
    
    NSString *url = [NSString stringWithFormat:@"https://www.google.dk/search?%@&start=%d", query, start];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString: url]]; // [HttpOperations sendGetRequest: url];

    //Pretend we are a desktop browser
    NSString* userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:43.0) Gecko/20100101 Firefox/43.0";
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
        NSError *err;
        NSData *responseData = data;
    
    
    
    //NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    }];
    
    return @"{}";
}
 */
        
+(NSArray *)ParseResultsFrom:(NSString *)responseBody
{
    
    NSError *err;
    NSRegularExpression *regex_pattern;
    BOOL simpleOut = [responseBody rangeOfString:@"sout=1"].length != 0;
    if(simpleOut)
    {
        //Works with &sout=1
        regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"(<td style=\"width:\\d{2}%;word-wrap:break-word\">)(.*?)(</td>)" options:0 error:&err];
    }
    else //assume we know the elaborate regex to find the interesting stuff
    {
        //regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"(class=\"rg_di)(.*?)(\\}</div></div>)" options:0 error:&err];
        //regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"\"ou\"\\s*:\\s*\"(.+?)\"" options:0 error:&err];
        
        //regex_pattern = [NSRegularExpression regularExpressionWithPattern:@">\\{(.+?)\\}<" options:0 error:&err];
        regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"(\\[\"[^\"]*\",\\d+,\\d+\\](\\n,)){2}" options:0 error:&err];

    }
    
    
    NSArray *matches = [regex_pattern matchesInString:responseBody options:0 range:NSMakeRange(0, responseBody.length) ];
    
    NSMutableArray *links = [[NSMutableArray alloc]init];
    
    for (NSTextCheckingResult *match in matches) {

        ImageInfo *ii = [[ImageInfo alloc] init];
        
        NSString *result = [responseBody substringWithRange: [match rangeAtIndex:0]];
        
        //Works with &sout=1
        if(simpleOut)
        {
            //ii.ImageURL = [result substringWithRange: [result rangeOfString:@"(?<=q=)(.*?)(?=\")" options:NSRegularExpressionSearch]];
     
            ii.ThumbURL = [result substringWithRange: [result rangeOfString:@"(?<=src=\")(.*?)(?=\")" options: NSRegularExpressionSearch]];
            ii.ImageURL = ii.ThumbURL;
            
        } else {
                    
            result = [NSString stringWithFormat:@"[%@]", result];
            NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonList = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            
            //ii.ImageURL = [result substringWithRange: [result rangeOfString:@"(?<=\"ou\":\")(.+?)(?=\")" options:NSRegularExpressionSearch]];
            
            ii.ImageURL = [[jsonList objectAtIndex: 1] objectAtIndex:0] ;
            
            //replace unicode
            ii.ImageURL =[[ii.ImageURL stringByReplacingOccurrencesOfString:@"\\u003d" withString:@"="] stringByReplacingOccurrencesOfString:@"\\u0026" withString:@"&"];
            
            ii.ThumbURL = [[jsonList objectAtIndex: 0] objectAtIndex:0] ;
            ii.ImageWidth = [[jsonList objectAtIndex: 1] objectAtIndex:1];
            ii.ImageHeight = [[jsonList objectAtIndex: 1] objectAtIndex:2];
            
            
            /*
            //@"(?<=\"ou\"\\s*:\\s*\")(.+?)(?=\")"
            ii.ThumbURL = [result substringWithRange: [result rangeOfString:@"(?<=\"tu\":\")(.*?)(?=\")" options: NSRegularExpressionSearch]];
            
            //replace unicode
            ii.ThumbURL =[[ii.ThumbURL stringByReplacingOccurrencesOfString:@"\\u003d" withString:@"="] stringByReplacingOccurrencesOfString:@"\\u0026" withString:@"&"];
             */
        }
        
        ii.Filename = [ii.ImageURL lastPathComponent];

        
        /*
        NSArray *values = [result componentsSeparatedByString:@"&amp;"];
        
        ii = [ImageInfo alloc];
        
        ii.GoogleSource = [[values objectAtIndex:1] stringByReplacingOccurrencesOfString:@"imgrefurl=" withString:@"" ];
        ii.GoogleID = [[values objectAtIndex:9] stringByReplacingOccurrencesOfString:@"tbnid=" withString:@""];
        ii.ImageURL = [[values objectAtIndex:0] substringWithRange: [[values objectAtIndex:0] rangeOfString:@"(?<=imgurl=)(.*?)$" options:NSRegularExpressionSearch]];
        
        //[[values objectAtIndex:0] stringByReplacingOccurrencesOfString:@"<a href=\"/imgres?imgurl=" withString:@""];
        ii.ImageWidth = [[values objectAtIndex:4] stringByReplacingOccurrencesOfString:@"w=" withString:@""];
        ii.ImageHeight = [[values objectAtIndex:3] stringByReplacingOccurrencesOfString:@"h="  withString:@""];
        ii.ThumbWidth = [[values objectAtIndex:11] stringByReplacingOccurrencesOfString:@"tbnw=" withString:@""];
        ii.ThumbHeight = [[values objectAtIndex:10] stringByReplacingOccurrencesOfString:@"tbnh=" withString:@""];
        ii.ThumbURL = [result substringWithRange: [result rangeOfString:@"(?<=src=\")(.*?)(?=\")" options:NSRegularExpressionSearch]];
        ii.Extension = [ii.ImageURL pathExtension];
        ii.Domain =  [result substringWithRange: [result rangeOfString:@"(?<=https?://)(.*?)(?=/)" options:NSRegularExpressionSearch]];
        ii.Filename = [ii.ImageURL lastPathComponent];
        */
        
        
        [links addObject:ii];
        
    }
    return links;
}

/*
+ (NSArray *)PerformSearchFrom: (NSString *)keyword fromIndex: (int)start onType: (NSString *)type withSafe: (BOOL) safe
{
    NSString *query = [NSString stringWithFormat:@"%@", [self buildQueryFromSearchTerm:keyword inTypes:type andSafetyOn:safe]];
    return [self PerformSearchUsingQuery:query fromIndex:start];
    
}
 */


+ (NSString *)buildQueryFromSearchTerm: (NSString *)keyword inTypes: (NSString *)searchType andSafetyOn: (BOOL)safe
{
    NSString * query = [NSString stringWithFormat: @"hl=en&safe=%@&sout=1&site=imghp&tbs=itp:%@&tbm=isch&q=%@", (safe ? @"on" : @"off"), [searchType lowercaseString], [keyword stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    return query;
}


@end
