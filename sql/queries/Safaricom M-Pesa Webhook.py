# mpesa_webhook.py
@app.route('/mpesa', methods=['POST'])
def handle_payment():
    data = request.json
    county = get_county(data['PhoneNumber'][:6])  # e.g. 254701 → Nairobi
    process_order(
        amount=data['Amount'],
        county_code=county['code'],
        carrier='Safaricom'
    )