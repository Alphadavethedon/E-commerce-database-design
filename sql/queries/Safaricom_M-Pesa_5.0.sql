import os
import re
import logging
from flask import Flask, request, jsonify
from werkzeug.exceptions import BadRequest, Unauthorized
from dotenv import load_dotenv
import psycopg2
from functools import wraps
from ratelimit import limits, sleep_and_retry

# Initialize Flask app
app = Flask(__name__)

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    filename='mpesa_webhook.log',
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

# Database connection (PostgreSQL example)
def get_db_connection():
    return psycopg2.connect(
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST')
    )

# M-Pesa prefix to county mapping (example)
mpesa_prefix_map = {
    '+2547': 'Nairobi',
    '+25411': 'Mombasa'
    # Add more prefixes as needed
}

# Rate limiting: 100 requests per minute
CALLS = 100
PERIOD = 60

# Validate M-Pesa API credentials (simplified example)
def verify_mpesa_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        expected_token = os.getenv('MPESA_API_TOKEN')
        if not auth_header or auth_header != f"Bearer {expected_token}":
            logger.error("Unauthorized request")
            raise Unauthorized("Invalid or missing authorization token")
        return f(*args, **kwargs)
    return decorated_function

# Process payment (example implementation)
def process_payment(amount, county, carrier, transaction_id, phone_number):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO payments (transaction_id, amount, county, carrier, phone_number, status)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT (transaction_id) DO NOTHING
            """,
            (transaction_id, amount, county, carrier, phone_number, 'completed')
        )
        conn.commit()
        logger.info(f"Processed payment: {transaction_id}, Amount: {amount}, County: {county}")
    except Exception as e:
        logger.error(f"Payment processing failed: {str(e)}")
        raise
    finally:
        cursor.close()
        conn.close()

# Webhook endpoint
@app.route('/mpesa', methods=['POST'])
@sleep_and_retry
@limits(calls=CALLS, period=PERIOD)
@verify_mpesa_auth
def callback():
    try:
        # Validate JSON payload
        if not request.is_json:
            logger.error("Invalid request: No JSON payload")
            raise BadRequest("Request must contain JSON")

        data = request.get_json()

        # Validate required fields
        required_fields = ['Amount', 'PhoneNumber', 'TransactionID']
        if not all(field in data for field in required_fields):
            logger.error(f"Missing required fields: {data}")
            raise BadRequest("Missing required fields")

        # Validate phone number format (e.g., +2547XXXXXXXX)
        phone_number = data['PhoneNumber']
        if not re.match(r'^\+254\d{9}$', phone_number):
            logger.error(f"Invalid phone number: {phone_number}")
            raise BadRequest("Invalid phone number format")

        # Validate amount
        amount = float(data['Amount'])
        if amount <= 0:
            logger.error(f"Invalid amount: {amount}")
            raise BadRequest("Amount must be positive")

        # Get county from phone prefix
        prefix = phone_number[:5]  # Adjusted to match example prefixes
        if prefix not in mpesa_prefix_map:
            logger.error(f"Unsupported prefix: {prefix}")
            return jsonify({
                "ResultCode": 1,
                "ResultDesc": f"Unsupported phone prefix: {prefix}"
            }), 400

        county = mpesa_prefix_map[prefix]
        transaction_id = data['TransactionID']

        # Check for duplicate transaction
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT status FROM payments WHERE transaction_id = %s",
            (transaction_id,)
        )
        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if result:
            logger.info(f"Duplicate transaction ignored: {transaction_id}")
            return jsonify({
                "ResultCode": 0,
                "ResultDesc": "Transaction already processed"
            }), 200

        # Process payment
        process_payment(
            amount=amount,
            county=county,
            carrier='Safaricom',
            transaction_id=transaction_id,
            phone_number=phone_number
        )

        return jsonify({
            "ResultCode": 0,
            "ResultDesc": "Payment processed successfully"
        }), 200

    except BadRequest as e:
        return jsonify({
            "ResultCode": 1,
            "ResultDesc": str(e)
        }), 400
    except Unauthorized as e:
        return jsonify({
            "ResultCode": 1,
            "ResultDesc": str(e)
        }), 401
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return jsonify({
            "ResultCode": 1,
            "ResultDesc": "Internal server error"
        }), 500

# Run the app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
