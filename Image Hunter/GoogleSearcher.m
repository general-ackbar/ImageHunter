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



+ (NSArray *)PerformSearchUsingQuery:(NSString *)query fromIndex:(int)start
{
    
    
    NSString *url = [NSString stringWithFormat:@"https://www.google.dk/search?%@&start=%d", query, start];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString: url]]; // [HttpOperations sendGetRequest: url];

    //Pretend we are a desktop browser
    NSString* userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:43.0) Gecko/20100101 Firefox/43.0";
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSError *err;
    NSURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    //Works with &sout=1
    //NSRegularExpression *regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"(<td style=\"width:\\d{2}%;word-wrap:break-word\">)(.*?)(</td>)" options:0 error:&err];
    
    NSRegularExpression *regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"(class=\"rg_di)(.*?)(\\}</div></div>)" options:0 error:&err];
    
    NSArray *matches = [regex_pattern matchesInString:responseBody options:0 range:NSMakeRange(0, responseBody.length) ];
    
    NSMutableArray *links = [[NSMutableArray alloc]init];
    

    
    for (NSTextCheckingResult *match in matches) {

        ImageInfo *ii = [[ImageInfo alloc] init];
        
        NSString *result = [responseBody substringWithRange: [match rangeAtIndex:0]];
        
        //Works with &sout=1
        /*
        ii.ImageURL = [result substringWithRange: [result rangeOfString:@"(?<=q=)(.*?)(?=\")" options:NSRegularExpressionSearch]];
        
        ii.ThumbURL = [result substringWithRange: [result rangeOfString:@"(?<=src=\")(.*?)(?=\")" options: NSRegularExpressionSearch]];
        */
        
        ii.ImageURL = [result substringWithRange: [result rangeOfString:@"(?<=imgurl=)(.*?)(?=&amp;imgref)" options:NSRegularExpressionSearch]];
        
        ii.ThumbURL = [[result substringWithRange: [result rangeOfString:@"(?<=\"tu\":\")(.*?)(?=\",\"tw\")" options: NSRegularExpressionSearch]] stringByReplacingOccurrencesOfString:@"\\u003d" withString:@"="];
        
        
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


+ (NSArray *)PerformSearchFrom: (NSString *)keyword fromIndex: (int)start onType: (NSString *)type withSafe: (BOOL) safe
{
    NSString *query = [NSString stringWithFormat:@"%@", [self buildQueryFromSearchTerm:keyword inTypes:type andSafetyOn:safe]];
    return [self PerformSearchUsingQuery:query fromIndex:start];
    
}


+ (NSString *)buildQueryFromSearchTerm: (NSString *)keyword inTypes: (NSString *)searchType andSafetyOn: (BOOL)safe
{
    NSString * query = [NSString stringWithFormat: @"hl=en&safe=%@&sout=1&site=imghp&tbs=itp:%@&tbm=isch&q=%@", (safe ? @"on" : @"off"), [searchType lowercaseString], [keyword stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    return query;
}


@end
