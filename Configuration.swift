//
//  Configuration.swift
//  RiteAid
//
//  Created by Sage Young on 4/25/16
//  Copyright (c) 2016 Fueled. All rights reserved.
//

import Foundation

struct Configuration {
	static var HockeyAppIdentifier: String {
		#if PRODUCTION
			return "a030ebd3e1964f7189f4712de7c72172"
		#else
			return "5995418ffc5d4e17a2c29868be68b5f7"
		#endif
	}

	static var APIBaseURL: String {
		#if PRODUCTION
			return "https://mobilecar6.riteaid.com/rest"
		#else
			return "https://mobilecar6.riteaid.com/rest"
		#endif
	}

	static var universalLinkHost: String {
		#if PRODUCTION
			return "riteaid.com"
		#else
			return "beta7.riteaid.com"
		#endif
	}

	static var StoreLocatorBaseURL: String {
		return "https://mbeta7.riteaid.com/services"
	}
	
	static var SSOBaseURL: String {
		return "https://mbeta7.riteaid.com/sso-mobile"
	}
	
	static var ECommerceURL: String {
		return "https://mbeta7.riteaid.com/external-redirect?program=ecommerce"
	}

	static var PassFileURl: String {
		return "https://mbeta7.riteaid.com/services/mobile/getWellnessCardPass"
	}
	
	static var TermsAndConditionsUrl: String {
		return "http://carcontent.riteaid.com/mobile/terms/android.html"
	}

	static var PrivacyUrl: String {
		return "http://carcontent.riteaid.com/mobile/privacy/android.html"
	}

	static var ContactUsUrl: String {
		return "http://carcontent.riteaid.com/mobile/contact_us/contact_us.html"
	}
	
	static var requestHeader: String {
		return "RiteAidMobile"
	}

	static var segmentKey: String {
		return "Y5rxlU3sdkSw5uzKq3JrXLup8ztQPnRk"
	}

	static var pharmacySignupURL: String {
		return "https://mbeta7.riteaid.com/my-pharmacy-enrollment?mobile=true&mobileApp=true"
	}

	static var connectWellnessPlentiURL: String {
		return "https://mbeta7.riteaid.com/connect-wellness-plenti"
	}

	static var finishLinkingPlentiURL: String {
		return "https://beta7.riteaid.com/transfer-to-plenti"
	}
	
	static var ForgotPasswordUrl: String {
		return "https://beta7.riteaid.com/password-recovery?mobile=true&mobileApp=true"
	}

	static var pharmacyMessageUrl: String {
		return "https://beta7.riteaid.com/pharmacy/services/my-pharmacy/my-secure-messages/&mobile=true"
	}

	struct Logs {
		static var HasLogFiles: Bool {
			#if DEBUG
				return true
			#elseif SNAPSHOT
				return true
			#elseif RELEASE
				return true
			#elseif PRODUCTION
				return false
			#endif
		}

		static var LogFileMaxSize: UInt64 {
			#if DEBUG
				return 1024 * 1024
			#elseif SNAPSHOT
				return 1024 * 1024
			#elseif RELEASE
				return 256 * 1024
			#elseif PRODUCTION
				return 0
			#endif
		}
		static var LogFileMaxNumber: UInt {
			#if DEBUG
				return 5
			#elseif SNAPSHOT
				return 5
			#elseif RELEASE
				return 5
			#elseif PRODUCTION
				return 0
			#endif
		}
		static var LogFileSizeToSendOnCrash: Int {
			#if DEBUG
				return 2 * 1024 * 1024
			#elseif SNAPSHOT
				return 2 * 1024 * 1024
			#elseif RELEASE
				return Int(self.LogFileMaxSize)
			#elseif PRODUCTION
				return 0
			#endif
		}
	}
}
