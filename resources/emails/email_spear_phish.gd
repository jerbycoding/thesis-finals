# email_spear_phish.gd
extends EmailResource

func _init():
	email_id = "EMAIL-SPEAR-001"
	sender = "CEO"
	subject = "Confidential: Q4 Financial Review"
	body = "Hi,\n\nI need you to review the attached Q4 financial report. This is confidential and should not be shared.\n\nPlease review and let me know your thoughts.\n\nThanks,\nCEO"
	attachments = ["financial_report.exe"]
	headers = {
		"status": {
			"spf": "PASS",
			"dkim": "PASS",
			"dmarc": "PASS"
		},
		"from_domain": "company.internal",
		"reply_to": "ceo@company.internal"
	}
	is_malicious = true
	is_urgent = false
	clues = ["bad_attachment", "spoofed_sender"]  # CEO wouldn't send .exe files
	related_ticket = "SPEAR-PHISH-001"
	suspicious_ip = "203.0.113.42"  # IP from attachment metadata (for cross-tool integration)
