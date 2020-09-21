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
#import "GoogleSearcher.h"


#define kSearchTypeArray @"", @"gray", @"trans", @"specific,isc:red", @"specific,isc:green", @"specific,isc:blue", nil


@implementation MainViewController
@synthesize SearchTextField, searchSafeSwitch, searchTypeSegments, spinner, searchClassicSwitch, searchSizeSegments, searchColorSegments, searchFormatSegments;



- (IBAction)performSearch:(UIButton *)sender {
    
    
    NSString *query = [self buildQuery];
    
    NSString *url = [NSString stringWithFormat:@"https://www.google.com/search?%@&start=%d", query, 0];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]  initWithURL:[NSURL URLWithString: url]];
    
    //Pretend we are a desktop browser
    NSString* userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:43.0) Gecko/20100101 Firefox/43.0";
    //NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36";
    
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error)
        {
            NSLog(@"%@", error.description);
        }
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSArray *links = [GoogleSearcher ParseResultsFrom:responseBody];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueToOverview" sender: [[NSArray alloc]initWithObjects:query,links, nil]];
        });
    }] resume];
}

- (NSString *)buildQuery
{
    NSString *type = [[searchTypeSegments titleForSegmentAtIndex: searchTypeSegments.selectedSegmentIndex] lowercaseString];
    NSString *color = [[[NSArray alloc] initWithObjects:kSearchTypeArray] objectAtIndex:searchColorSegments.selectedSegmentIndex];
    NSString *size = [[[searchSizeSegments titleForSegmentAtIndex:searchSizeSegments.selectedSegmentIndex] lowercaseString] substringToIndex:1];
    NSString *format = [[[searchFormatSegments titleForSegmentAtIndex:searchFormatSegments.selectedSegmentIndex] lowercaseString] substringToIndex:1];

    
    NSString *options = [[NSString stringWithFormat:@"tbs=ic:%@,isz:%@,itp:%@,iar:%@", color,size, type, format] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    //NSString * query = [NSString stringWithFormat: @"hl=en&safe=%@&site=imghp&tbs=itp:%@&tbm=isch&q=%@&sout=%@&gs_l=img", (searchSafeSwitch.isOn ? @"on" : @"off"), [[searchTypeSegments titleForSegmentAtIndex: searchTypeSegments.selectedSegmentIndex] lowercaseString], [SearchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"], (searchClassicSwitch.isOn ? @"1" : @"0")];
    NSString * query = [NSString stringWithFormat: @"hl=en&safe=%@&site=imghp&%@&tbm=isch&q=%@&sout=%@&gs_l=img", (searchSafeSwitch.isOn ? @"on" : @"off"), options, [SearchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"], (searchClassicSwitch.isOn ? @"1" : @"0")];
    
    
    return query;
}

- (IBAction)dismissKeyboard:(id)sender {
            [SearchTextField resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GalleryViewController *dest = [segue destinationViewController]; //topViewController];
    
    //Set values
    dest.requestData = [((NSArray *)sender) objectAtIndex:1]  ;
    dest.query = [((NSArray *)sender) objectAtIndex:0]  ;
    dest.title = self.SearchTextField.text;

}
@end
