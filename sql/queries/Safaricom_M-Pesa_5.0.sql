# Updated Python webhook
@app.route('/mpesa', methods=['POST'])
def callback():
    try:
        data = request.get_json()
        county = mpesa_prefix_map[data['PhoneNumber'][:4]]
        process_payment(
            amount=data['Amount'],
            county=county,
            carrier='Safaricom'
        )
        return jsonify({"ResultCode": 0})
    except KeyError:
        log_error(f"Unsupported prefix: {data['PhoneNumber'][:4]}")
        return jsonify({"ResultCode": 1})