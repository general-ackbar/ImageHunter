//
//  HttpOperations.m
//  Media Library
//
//  Created by Jonatan Yde on 30/01/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "HttpOperations.h"

@implementation HttpOperations


+(void)performLoginAt:(NSString *)url withUser:(NSString *)username andPassword:(NSString *)password
{
    
    //Get index-page
    NSMutableURLRequest *request = [self sendGetRequest:url];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    
    
    //Retrieve request_token & sechash
    NSRegularExpression *viewstate_regex = [NSRegularExpression regularExpressionWithPattern:@"(__VIEWSTATE\".*?value=\")(.*?)(?=\")" options:0 error:&err];
    NSTextCheckingResult *viewstate_matces = [viewstate_regex firstMatchInString:responseBody options:0 range: NSMakeRange(0, responseBody.length) ];
    NSString *viewstate = [responseBody substringWithRange: [viewstate_matces rangeAtIndex:2]];
    
    
    NSRegularExpression *eventvalidation_regex = [NSRegularExpression regularExpressionWithPattern:@"(__EVENTVALIDATION\".*?value=\")(.*?)(?=\")" options:0 error:&err];
    NSTextCheckingResult *eventvalidation_matces = [eventvalidation_regex firstMatchInString:responseBody options:0 range: NSMakeRange(0, responseBody.length) ];
    NSString *eventvalidation = [responseBody substringWithRange: [eventvalidation_matces rangeAtIndex:2]];
    
    
    
    //prepare all POST values for login
    NSMutableDictionary *parm = [NSMutableDictionary dictionary]; //[[NSDictionary alloc] initWithObjectsAndKeys: nil];
    
    [parm setValue: @"Log In" forKey: @"ctl00$ContentPlaceHolderContent$Login1$LoginButton"];
    [parm setValue: username forKey:@"ctl00$ContentPlaceHolderContent$Login1$UserName"];
    [parm setValue: password forKey:@"ctl00$ContentPlaceHolderContent$Login1$Password"];
    [parm setValue: viewstate forKey:@"__VIEWSTATE"];
    [parm setValue: eventvalidation forKey:@"__EVENTVALIDATION"];
    
    //Perform login
    request = [self sendPostRequest: url withParameters:parm];
    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    
    //Retrieve SessionID for specific user
    //responseBody = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    /*
     NSRegularExpression *sessionid_regex = [NSRegularExpression regularExpressionWithPattern:@"(ASP.NET_SessionId\".*?value=\")(.*?)(?=\")" options:0 error:&err];
     NSTextCheckingResult *sessionid_matces = [sessionid_regex firstMatchInString:responseBody options:0 range: NSMakeRange(0, responseBody.length) ];
     NSString *sessonid = [NSString stringWithFormat:@"%i",[[responseBody substringWithRange: [sessionid_matces rangeAtIndex:2]] intValue] + 1];
     
     NSLog(@"%@", sessonid);
     
     NSDictionary *headerFields = [(NSHTTPURLResponse*)response allHeaderFields];
     NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:headerFields];
     */
    
    
    /*
     request = [self sendGetRequest:@"http://www.joyd.dk/Media/Default.aspx?f=/video"];
     
     responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
     responseBody = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
     */
    
    
}

#define kServerConnectionTimeout 60

+ (NSMutableURLRequest *)sendPostRequest:(NSString *)url withParameters:(NSDictionary *)parameters
{
    NSMutableData *reqData = [NSMutableData data];
    NSURL *encUrl;
    encUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:encUrl];
    [request setHTTPShouldHandleCookies:YES];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = kServerConnectionTimeout;
    NSString *stringBoundary = @"Multipart-Boundary"; // TODO - randomize this
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"",stringBoundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [reqData appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    for (id key in [parameters allKeys])
    {
        if (![key isEqualToString:@"data"])
        {
            NSString *val = [parameters objectForKey:key];
            if (val != nil)
            {
                [reqData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"Content-Type: text/plain\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: 8bit\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"%@",val] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    // send binary part last
    if ([parameters objectForKey:@"data"])
    {
        NSString *key  = @"data";
        NSData *fileData = [parameters objectForKey:key];
        if (fileData != nil)
        {
            [reqData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"FILE1\";filename=\"upload.file\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [reqData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [reqData appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [reqData appendData:fileData];
            [reqData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    NSString * dataLength = [NSString stringWithFormat:@"%d", [reqData length]];
    [request addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    
    request.HTTPBody = reqData;
    //NSLog(@"postBody=%@", [[NSString alloc] initWithData:reqData encoding:NSASCIIStringEncoding]);
    
    return request;
}

+ (NSMutableURLRequest *)sendGetRequest:(NSString *)url
{
    NSURL *encUrl;
    encUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:encUrl];
    [request setHTTPShouldHandleCookies:YES];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = kServerConnectionTimeout;
    
    return request;
}

@end
