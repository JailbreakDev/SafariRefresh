@interface BrowserController : UIViewController
+(id)sharedBrowserController;
-(void)reloadKeyPressed;
-(UIRefreshControl *)createReloadPageControl; //new
@end

UIRefreshControl *reloadPageControl = nil;

%hook BrowserController

+(id)sharedBrowserController {
	self = %orig;

	if (self) {
		@try {
			UIScrollView *scrollView = [(BrowserController *)self valueForKey:@"_scrollView"];
			if (scrollView) {
				[scrollView addSubview:[(BrowserController *)self createReloadPageControl]];
			}
		} @catch (NSException *e) {
			NSLog(@"[SafariRefresh] caught exception: %@",e);
		}
	}

	return self;
}

%new

-(UIRefreshControl *)createReloadPageControl {
	if (reloadPageControl && reloadPageControl.superview) {
		[reloadPageControl removeFromSuperview];
		reloadPageControl = nil;
	}
	if (!reloadPageControl) {
		reloadPageControl = [[UIRefreshControl alloc] init];
		[reloadPageControl addTarget:self action:@selector(reloadKeyPressed) forControlEvents:UIControlEventValueChanged];
	}
	return reloadPageControl;
}

-(void)resume {
	@try {
		UIScrollView *scrollView = [(BrowserController *)self valueForKey:@"_scrollView"];
		if (scrollView) {
			[scrollView addSubview:[self createReloadPageControl]];
		}
	} @catch (NSException *e) {
		NSLog(@"[SafariRefresh] caught exception: %@",e);
	}
	%orig;
}

-(void)reloadKeyPressed {
	if (reloadPageControl) {
		[reloadPageControl endRefreshing];
	}
	%orig;
}

-(void)scrollViewWasRemoved:(id)removed {
	%orig;
	if (reloadPageControl && reloadPageControl.superview) {
		[reloadPageControl removeFromSuperview];
		reloadPageControl = nil;
	}
}

%end