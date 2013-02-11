//
//  MainViewController.m
//  Image Hunter
//
//  Created by Jonatan Yde on 07/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "MainViewController.h"
#import "HttpOperations.h"
#import "ImageInfo.h"
#import "GalleryViewController.h"

@implementation MainViewController
@synthesize SearchTextField;


- (IBAction)performSearch:(UIButton *)sender {
    
    NSString *url = [NSString stringWithFormat:@"https://www.google.dk/search?hl=en&safe=off&sout=1&site=imghp&tbm=isch&q=%@", [SearchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    NSMutableURLRequest *request = [HttpOperations sendGetRequest:url];
    
    NSError *err;
    NSURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseBody = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    NSRegularExpression *regex_pattern = [NSRegularExpression regularExpressionWithPattern:@"(<td style=\"width:\\d{2}%;word-wrap:break-word\">)(.*?)(</td>)" options:0 error:&err];
    
    NSArray *matches = [regex_pattern matchesInString:responseBody options:0 range:NSMakeRange(0, responseBody.length) ];

    NSMutableArray *links = [[NSMutableArray alloc]init];
    
    ImageInfo *ii;
    for (NSTextCheckingResult *match in matches) {
        
        NSString *result = [responseBody substringWithRange: [match rangeAtIndex:0]];
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
        
        [links addObject:ii];
    }

    [self performSegueWithIdentifier:@"segueToOverview" sender:links];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GalleryViewController *dest = [segue destinationViewController]; //topViewController];
    
    //Set values
    dest.data = sender;
}
@end
