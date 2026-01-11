# email_phishing_01.gd
extends EmailResource

func _init():
	email_id = "EMAIL-PHISH-001"
	sender = "External"
	subject = "URGENT: Verify Your Account Immediately"
	body = "Dear User,\n\nWe have detected suspicious activity on your account. Please verify your credentials immediately by clicking the link below.\n\n[Click here to verify]\n\nFailure to verify within 24 hours will result in account suspension.\n\nBest regards,\nSecurity Team"
	attachments = []
	headers = {
		"status": {
			"spf": "FAIL",
			"dkim": "FAIL",
			"dmarc": "FAIL"
		},
		"from_domain": "suspicious-domain.com",
		"reply_to": "noreply@suspicious-domain.com"
	}
	is_malicious = true
	is_urgent = true
	clues = ["suspicious_link", "spoofed_sender", "suspicious_domain"]
	suspicious_domain = "suspicious-domain.com"
	related_ticket = "PHISH-001"
