# res://scripts/Phishing.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

@onready var header:      Label         = $Header
@onready var email_box:   Panel         = $EmailBox
@onready var body:        RichTextLabel = $EmailBox/Body
@onready var phish_btn:   Button        = $Buttons/PhishBtn
@onready var legit_btn:   Button        = $Buttons/LegitBtn
@onready var feedback:    Label         = $Feedback
@onready var next_btn:    Button        = $NextBtn
@onready var back_btn:    Button        = $BackBtn

@onready var intro_popup:     Control = $IntroPopup
@onready var intro_title:     Label   = $IntroPopup/VBox/Title
@onready var intro_body:      Label   = $IntroPopup/VBox/Body
@onready var intro_start_btn: Button  = $IntroPopup/VBox/StartBtn
@onready var overlay: Control = $IntroPopupOverlay


var debug_label: Label

var items: Array = [
	{
		"text":
			"From: \"Shipping Support\" <support@shipp1ng-updates.com>\n"
			+ "Subject: Package on hold – fee required\n\n"
			+ "Hello,\n\n"
			+ "We attempted to deliver your package today but were unable to confirm your address.\n"
			+ "To avoid RETURN TO SENDER, you must pay a small verification fee of $1.00 within 24 hours.\n\n"
			+ "Please confirm your card details and billing address at the secure link below:\n"
			+ "https://track-my-parcel-secure.com/verify-identity\n\n"
			+ "Failure to act will result in permanent cancellation of your shipment.\n\n"
			+ "Thank you,\n"
			+ "Shipping Support Team",
		"is_phish": true
	},
	{
		"text":
			"From: IT Helpdesk <it-helpdesk@campus.edu>\n"
			+ "Subject: Planned maintenance – Wi-Fi and email\n\n"
			+ "Hi all,\n\n"
			+ "This is a notice that campus Wi-Fi and email may be intermittently unavailable\n"
			+ "TONIGHT from 11:00 PM to 1:00 AM during scheduled maintenance.\n\n"
			+ "No action is required from you. You do NOT need to change your password,\n"
			+ "and we will never ask for your login information via email.\n\n"
			+ "If you have any questions, please open a ticket at the official helpdesk portal.\n\n"
			+ "Thanks,\n"
			+ "Campus IT Services",
		"is_phish": false
	},
	{
		"text":
			"From: \"Account Security\" <security@paypall-support.com>\n"
			+ "Subject: URGENT – Account will be closed in 3 hours\n\n"
			+ "Dear Customer,\n\n"
			+ "We have detected suspicious activity in your account and will CLOSE IT PERMANENTLY\n"
			+ "in the next 3 hours if you do not verify your identity.\n\n"
			+ "To keep your account active, click the link below and enter:\n"
			+ " • Full name\n"
			+ " • Date of birth\n"
			+ " • Card number and CVV\n"
			+ " • Social Security number\n\n"
			+ "https://paypall-secure-check.com/login\n\n"
			+ "This is your FINAL WARNING. Do not ignore this message.\n\n"
			+ "Security Team",
		"is_phish": true
	},
	{
	"text":
        "From: Team Lead <manager@company.com>\n"
		+ "Subject: Slides from today’s meeting\n\n"
		+ "Hi everyone,\n\n"
		+ "Thanks for joining the project sync today. As promised, the slide deck is attached\n"
		+ "as a PDF. It includes:\n"
		+ " • Timeline for the next sprint\n"
		+ " • Updated task owners\n"
		+ " • Links to design documents in our internal drive\n\n"
		+ "Let me know if anything looks off or if you need clarification.\n\n"
		+ "Best,\n"
		+ "Alex",
	"is_phish": false
},
{
	"text":
        "From: \"Security Notification\" <no-reply@secure-login.com>\n"
		+ "Subject: New sign-in from unknown device\n\n"
		+ "Hello,\n\n"
		+ "We noticed a new login to your account from:\n"
		+ " • Location: Chicago, IL (approximate)\n"
		+ " • Device: Windows PC\n"
		+ " • Time: 2:14 AM\n\n"
		+ "If this was you, no further action is needed.\n"
		+ "If this was NOT you, please sign in to your account by clicking the button below\n"
		+ "and change your password directly on our official website. Do NOT share your password with anyone.\n\n"
		+ "Go to account: https://www.examplebank.com\n\n"
		+ "Thank you,\n"
		+ "Example Bank Security",
	"is_phish": false
},

	{
		"text":
			"From: \"HR Payroll\" <hr-payroll@companny-pay.com>\n"
			+ "Subject: Update your direct deposit IMMEDIATELY\n\n"
			+ "Dear Employee,\n\n"
			+ "Our records show an ERROR with your direct deposit information.\n"
			+ "If you do not correct this within the NEXT 60 MINUTES, your paycheck will\n"
			+ "be delayed for 30 days.\n\n"
			+ "Use the attached Excel file “Payroll_Update.xlsm” and enable macros to\n"
			+ "update your bank account and routing number.\n\n"
			+ "DO NOT contact HR by phone, this process is AUTOMATED.\n\n"
			+ "HR Payroll Automation",
		"is_phish": true
	},
	{
		"text":
			"From: Campus Library <library@campus.edu>\n"
			+ "Subject: Reminder – Book due soon\n\n"
			+ "Hi,\n\n"
			+ "This is a friendly reminder that the following item is due in 3 days:\n"
			+ " • \"Introduction to Cybersecurity\" (Book ID: 123456)\n\n"
			+ "You can renew your loan by logging into the official library portal or visiting\n"
			+ "the front desk during opening hours. We will never ask for your password in email.\n\n"
			+ "Thank you,\n"
			+ "Campus Library",
		"is_phish": false
	},
	{
		"text":
			"From: \"Tax Refund Center\" <refund@irs-fastpay.com>\n"
			+ "Subject: You are eligible for an immediate tax refund\n\n"
			+ "Dear Taxpayer,\n\n"
			+ "Our system shows that you are entitled to a special tax REFUND of $842.17.\n"
			+ "To receive your money instantly, you must confirm your identity by filling\n"
			+ "out the secure refund form in the next 12 hours.\n\n"
			+ "Please provide your:\n"
			+ " • Full name and address\n"
			+ " • Date of birth\n"
			+ " • Bank account and routing number\n"
			+ " • Social Security number\n\n"
			+ "Access your refund here:\n"
			+ "https://irs-fastpay-refunds.com/claim\n\n"
			+ "Failure to respond will result in loss of this refund.\n\n"
			+ "IRS Refund Department",
		"is_phish": true
	}
]

var index: int = 0
var answered: bool = false


func _ready() -> void:
	debug_label = Label.new()
	debug_label.modulate = Color(0, 0, 0)
	add_child(debug_label)
	_show("[Phishing] init")

	if not _verify_nodes():
		_dump_tree_paths()
		return

	header.text = "Phishing Classifier"
	phish_btn.text = "Phish"
	legit_btn.text = "Legit"
	next_btn.text = "Next"
	back_btn.text = "Back"

	phish_btn.disabled = false
	legit_btn.disabled = false
	phish_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	legit_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	phish_btn.pressed.connect(func(): _answer(true))
	legit_btn.pressed.connect(func(): _answer(false))
	next_btn.pressed.connect(_next)
	back_btn.pressed.connect(func(): Transition.change_scene(SCN_HUB))

	_setup_intro_popup()
	_show_intro(true)


func _setup_intro_popup() -> void:
	if intro_title:
		intro_title.text = "Phishing Game – Overview"

	if intro_body:
		intro_body.text = (
			"Goal: Learn how to spot phishing emails and messages.\n\n"
			+ "In this activity you'll see different messages and must decide\n"
			+ "whether they are SAFE or PHISHING.\n\n"
			+ "Look for red flags like:\n"
			+ " • Urgent or threatening language (\"act now or your account is closed\")\n"
			+ " • Requests for passwords or personal information\n"
			+ " • Suspicious links or email addresses\n"
			+ " • Spelling/grammar errors or weird formatting."
		)

	if intro_start_btn:
		intro_start_btn.text = "Got it – Start"
		intro_start_btn.pressed.connect(_on_intro_start_pressed)


func _show_intro(show: bool) -> void:
	if overlay:
		overlay.visible = show

	if intro_popup:
		intro_popup.visible = show

	var enabled := not show
	phish_btn.disabled = not enabled
	legit_btn.disabled = not enabled
	next_btn.disabled = true   # always disabled until answer
	back_btn.disabled = not enabled



func _on_intro_start_pressed() -> void:
	_show_intro(false)
	_show_current()


func _verify_nodes() -> bool:
	var req = {
		"Header": header,
		"EmailBox": email_box,
		"EmailBox/Body": body,
		"Buttons/PhishBtn": phish_btn,
		"Buttons/LegitBtn": legit_btn,
		"Feedback": feedback,
		"NextBtn": next_btn,
		"BackBtn": back_btn,
		"IntroPopup": intro_popup,
		"IntroPopup/Title": intro_title,
		"IntroPopup/Body": intro_body,
		"IntroPopup/StartBtn": intro_start_btn,
	}
	for k in req.keys():
		if req[k] == null:
			_fail("Missing node: " + k + " (check names/paths in Phishing.tscn)")
			return false
	return true


func _show_current() -> void:
	var item = items[index]
	body.text = item["text"]
	feedback.text = ""
	answered = false
	next_btn.disabled = true


func _answer(guess_is_phish: bool) -> void:
	if answered:
		return
	answered = true

	var item = items[index]
	var correct: bool = (guess_is_phish == item["is_phish"])

	if correct:
		if typeof(Game) != TYPE_NIL:
			Game.add_score(1)
		feedback.text = "Correct!"
	else:
		feedback.text = "Oops!"

	next_btn.disabled = false


func _next() -> void:
	index += 1
	if index >= items.size():
		if typeof(Game) != TYPE_NIL:
			Game.unlock_achievement("phishing_pro")
			Game.last_result = "win"
		Transition.change_scene(SCN_HUB)
	else:
		_show_current()


# ---- helpers
func _show(msg: String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg


func _fail(msg: String) -> void:
	push_error(msg)
	_show(msg)


func _dump_tree_paths() -> void:
	print("[Phishing] Scene tree:")
	_dump(self, "")


func _dump(n: Node, indent: String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
