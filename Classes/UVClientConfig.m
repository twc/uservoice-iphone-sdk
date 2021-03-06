//
//  UVClientConfig.m
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "HTTPRiot.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVResponseDelegate.h"
#import "UVForum.h"
#import "UVSubject.h"
#import "UVQuestion.h"
#import "UVUser.h"
#import "UVSubdomain.h"

@implementation UVClientConfig

@synthesize questionsEnabled;
@synthesize ticketsEnabled;
@synthesize forum;
@synthesize welcome;
@synthesize itunesApplicationId;
@synthesize questions;
@synthesize subdomain;
@synthesize customFields;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)getWithDelegate:(id)delegate {
	return [self getPath:[self apiPath:@"/client.json"]
			  withParams:nil
				  target:delegate
				selector:@selector(didRetrieveClientConfig:)];
}

+ (void)processModel:(id)model {
	[UVSession currentSession].clientConfig = model;
}

+ (CGFloat)getScreenWidth
{
	CGRect appFrame = [[UIScreen mainScreen] bounds];
    
	CGFloat screenWidth;
	if (([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft) || ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight))
	{
		screenWidth = appFrame.size.height;
	}
	else 
	{
		screenWidth = appFrame.size.width;
	}
	
	return screenWidth;
}

+ (CGFloat)getScreenHeight
{
	CGRect appFrame = [[UIScreen mainScreen] bounds];
	CGFloat screenHeight;
	if (([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft) || ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight))
	{
		screenHeight = appFrame.size.width;
	}
	else 
	{
		screenHeight = appFrame.size.height;		
	}
	
	return screenHeight;	
}

// Methods to store initial launch orientation of UserVoice (and then use that orientation until UserVoice is dismissed again)
// The UVBaseViewController class uses getOrientation: to determine the allowed orientation, and therefore all the controllers inherit this
+ (UIDeviceOrientation)getOrientation
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int orientation = [userDefaults integerForKey:@"UVOrientation"];
	
	if (orientation)
	{
		return (UIDeviceOrientation)orientation;
	}
	else 
	{
		return UIDeviceOrientationPortrait;
	}
}

+ (void)setOrientation
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int orientation = (int)[UIApplication sharedApplication].statusBarOrientation; 
	
	[userDefaults setInteger:orientation forKey:@"UVOrientation"];	
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if ((self = [super init])) {
        if ([dict objectForKey:@"questions_enabled"] != [NSNull null]) {
            self.questionsEnabled = [(NSNumber *)[dict objectForKey:@"questions_enabled"] boolValue];
        }
        
        if ([dict objectForKey:@"tickets_enabled"] != [NSNull null]) {
            self.ticketsEnabled = [(NSNumber *)[dict objectForKey:@"tickets_enabled"] boolValue];
        }
        
		self.welcome = [self objectOrNilForDict:dict key:@"welcome"];
		self.itunesApplicationId = [self objectOrNilForDict:dict key:@"identifier_external"];
		
		// get the forum
		NSDictionary *forumDict = [self objectOrNilForDict:dict key:@"forum"];
		UVForum *theForum = [[UVForum alloc] initWithDictionary:forumDict];
		self.forum = theForum;
		[theForum release];

		// get the subdomain
		NSDictionary *subdomainDict = [self objectOrNilForDict:dict key:@"subdomain"];
		UVSubdomain *theSubdomain = [[UVSubdomain alloc] initWithDictionary:subdomainDict];
		self.subdomain = theSubdomain;
		[theSubdomain release];
		
		// get the questions
		NSDictionary *questionsDict = [self objectOrNilForDict:dict key:@"questions"];
		if (questionsDict && [questionsDict count] > 0) {
			NSMutableArray *theQuestions = [NSMutableArray arrayWithCapacity:[questionsDict count]];
			for (NSDictionary *questionDict in questionsDict) {
				UVQuestion *question = [[UVQuestion alloc] initWithDictionary:questionDict];
				[theQuestions addObject:question];
				[question release];
			}
			self.questions = theQuestions;
		}
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"forumId: %d\nquestions_enabled: %d", self.forum.forumId, self.questionsEnabled];
}

- (void)dealloc {
    self.forum = nil;
    self.subdomain = nil;
    self.welcome = nil;
    self.itunesApplicationId = nil;
    self.questions = nil;
    self.customFields = nil;
    [super dealloc];
}

@end
