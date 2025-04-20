# ussd_menus.py
COUNTY_MENUS = {
    47: {  # Nairobi
        '1': 'English',
        '2': 'Sheng'
    },
    3: {   # Kilifi
        '1': 'Swahili',
        '2': 'Giriama'
    }
    # ... all 47 counties
}

def build_menu(phone):
    county = phone_prefix_db[phone[:6]]
    return f"CON Karibu {county_name[county]}\n" + \
           "\n".join([f"{k}. {v}" for k,v in COUNTY_MENUS[county].items()])