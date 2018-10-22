//
//  TermsOfServiceViewController.m
//  LoudHailer
//
//  Created by Kiwitech on 24/09/14.
//  Copyright (c) 2014 kiwitech. All rights reserved.
//

#import "TermsOfServiceViewController.h"
#import "AppManager.h"
#define TermsAndServiceHTML @"Use of this application is governed by the Loud-Hailer End User License Agreement, the most current of which is available at <a href='https://www.loud-hailer.com/eula/'>loud-hailer.com/eula-html</a>. <br/><br/>Collection and use of data are subject to Loud-Hailer’s Privacy Policy, the most current version of which is available at <a href='https://www.loud-hailer.com/privacy/'>loud-hailer.com/privacy.html/</a>."

@interface TermsOfServiceViewController ()<UIWebViewDelegate>
{
    __weak IBOutlet UILabel *_tosTextLbl;
    __weak IBOutlet UIWebView *_webView;
    BOOL _isAgree;
}

- (IBAction)agreeButtonClicked:(UIButton *)sender;
@end

@implementation TermsOfServiceViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %@;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"Aileron-Regular", [NSNumber numberWithInt:14], TermsAndServiceHTML];
    [_webView loadHTMLString:myDescriptionHTML baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction

- (IBAction)acceptClicked:(id)sender
{
    if (_isAgree)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(didAcceptTOS:)])
            [_delegate didAcceptTOS:YES];
        [self popMe];
    }
    else
    {
        [AppManager showAlertWithTitle:@"Alert!" Body:@"Please click on agree button to accept."];
    }
}

- (IBAction)declineClicked:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(didAcceptTOS:)])
        [_delegate didAcceptTOS:NO];
    [self popMe];
}

#pragma mark other methods

// pop
- (void)popMe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)agreeButtonClicked:(UIButton *)sender
{
    [sender setSelected:![sender isSelected]];
    _isAgree = [sender isSelected];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked )
    {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

@end
