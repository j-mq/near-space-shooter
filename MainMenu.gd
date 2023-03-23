extends Node2D

const CONTRACT_NAME = "dev-1679115038294-40250639006395"

const NFT_CONTRACT = "cottonbottom.testnet"

onready var login_button = $LoginButton
onready var player_name_label = $PlayerNameLabel
onready var nfts_grid = $NFTsGrid
onready var owned_nft = $NFTsGrid/OwnedNFT
onready var nft_picture = $NFTsGrid/NFTPicture

#Check if connection exists, if not, connnect to testnet
var config = {
	"network_id": "testnet",
	"node_url": "https://rpc.testnet.near.org",
	"wallet_url": "https://wallet.testnet.near.org",
}
var wallet_connection

func _ready():
	player_name_label.hide()
	owned_nft.hide()
	nft_picture.hide()
	
	if Near.near_connection == null:
		Near.start_connection(config)
	
	#Connect wallet
	wallet_connection = WalletConnection.new(Near.near_connection)
	wallet_connection.connect("user_signed_in", self, "_on_user_signed_in")
	wallet_connection.connect("user_signed_out", self, "_on_user_signed_out")
	
	if wallet_connection.is_signed_in():
		_on_user_signed_in(wallet_connection)

func _on_user_signed_in(wallet: WalletConnection):
	login_button.set_text("Sign Out")
	player_name_label.show()
	
	#Set name on label
	var accountId = wallet.get_account_id()
	player_name_label.set_text(accountId)
	
	#get nfts data
	var args = {"account_id": accountId}
	get_nfts(args)

func get_nfts(args):
	var result = Near.call_view_method(NFT_CONTRACT, "nft_tokens_for_owner", args)
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
		#print(result.data)
		var json_data = JSON.parse(result.data)
		var nfts: Array = json_data.result
		
		for nft in nfts:
			var nft_label = owned_nft.duplicate()
			nft_label.set_text(nft.token_id)
			nfts_grid.add_child(nft_label)
			nft_label.show()
			
			var nft_url = nft.metadata.media
			get_image(nft_url)
			
			
	if result.has("error"):
		print('some error happened')
		
		
func get_image(nft_url):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(nft_url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	var texture_rect = TextureRect.new()
	nfts_grid.add_child(texture_rect)
	texture_rect.texture = texture

func _on_user_signed_out(wallet: WalletConnection):
	login_button.set_text("Sign In")
	player_name_label.hide()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_HighScoresButton_pressed():
	get_tree().change_scene("res://HighScoresMenu.tscn")
	
func _on_LoginButton_pressed():
	if wallet_connection.is_signed_in():
		wallet_connection.sign_out()
	else:
		wallet_connection.sign_in(CONTRACT_NAME)
