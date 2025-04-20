# ussd_airtel.py
def airtel_menu(phone):
    county_code = phone[:6]
    if county_code in ['25470', '25471']:  # Nairobi/Mombasa
        return "CON 1. English\n2. Swahili"
    else:
        return "CON 1. Swahili\n2. Local Language"