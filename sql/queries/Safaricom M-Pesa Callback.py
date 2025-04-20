# safaricom_webhook.py
@app.route('/mpesa-callback', methods=['POST'])
def handle_callback():
    data = request.json
    if data['BusinessShortCode'] == '123456':  # Your paybill
        process_payment(
            amount=data['TransAmount'],
            phone=data['PhoneNumber'],
            county=mpesa_prefix_map[data['PhoneNumber'][:6]]
        )
    return jsonify({"ResultCode": 0})