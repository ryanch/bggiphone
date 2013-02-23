/*
 Copyright 2010 Petteri Kamppuri
 
 Licensed under the Apache License, Version 2.0 (the "License"); 
 you may not use this file except in compliance with the License. 
 You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
 
 Unless required by applicable law or agreed to in writing, software distributed under the 
 License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
 either express or implied. See the License for the specific 
 language governing permissions and limitations under the License. 
 */ 

//
//  MessageThreadViewController.h
//  BGG
//
//  Created by Petteri Kamppuri on 3.1.2010.
//  Copyright 2010 Petteri Kamppuri. All rights reserved.
//

#import "LoadingViewController.h"


@class BGGThread;


@interface MessageThreadViewController : LoadingViewController
{
	IBOutlet UIWebView * webView;
	IBOutlet UIActivityIndicatorView * loadingView;
	
	BGGThread	*thread;
}

@property (nonatomic, readwrite, strong) UIWebView * webView;
@property (nonatomic, readwrite, strong) UIActivityIndicatorView * loadingView;

@property (nonatomic, readwrite, strong) BGGThread *thread;

@end
