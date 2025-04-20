# payment_gateway.py
class MpesaProcessor:
    def __init__(self, county_code):
        self.fees = {
            47: {'Safaricom': 0.01, 'Airtel': 0.015},  # Nairobi
            1: {'Safaricom': 0.02},  # Mombasa
            # ... other counties
        }
    
    def charge(self, amount, phone):
        carrier = self.detect_carrier(phone)  # Uses prefix database
        fee_rate = self.fees[self.county][carrier]
        return amount * (1 + fee_rate)