# Sample USSD routing
def handle_ussd(phone, input):
    county = detect_county(phone)  # First 4 digits mapping
    carrier = detect_carrier(phone)
    
    if "1*1" in input:  # Browse products
        return show_county_products(county, carrier)
    elif "1*2" in input: # Check prices
        return format_response(
            f"CON Prices for {get_county_name(county)}:\n"
            f"1. Safaricom - {get_carrier_fee('Safaricom', county)}\n"
            f"2. Airtel - {get_carrier_fee('Airtel', county)}\n"
            f"3. Telkom - {get_carrier_fee('Telkom', county)}"
        )