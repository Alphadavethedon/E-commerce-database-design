# 🛍️ E-Commerce Database System

A well-structured database design for an e-commerce platform tailored for Kenya and Africa.

## 📘 Features
- Comprehensive ERD
- Schema SQL scripts
- Sample data for testing
- Business insights queries
- Dockerized setup

## 📁 Structure
- `01_schema.sql`: Core schema creation
- `02_data.sql`: Sample data insertion
- `business_insights.sql`: Data-driven insights (e.g., top products, average delivery times)

## 📊 ERD Preview
![ERD](./ERD/diagram.png)

## 🐳 Docker Setup
```bash
docker-compose up

ecommerce_project/ ├── apps/ │ ├── multi_tenant/ │ │ ├── models.py # Tenant model with custom settings │ │ └── middleware.py # Tenant identification middleware │ │ │ ├── payments/ │ │ ├── models.py # PaymentTransaction, Gateway │ │ ├── mpesa.py # M-Pesa integration │ │ └── flutterwave.py # Flutterwave integration │ │ │ ├── fulfillment/ │ │ ├── models.py # DeliveryZone, PickupStation │ │ └── sendy_integration.py │ │ │ ├── ai/ │ │ ├── models.py # Recommendation models │ │ └── recommenders.py # ML recommendation logic │ │ │ ├── risk/ │ │ ├── models.py # FraudRule, FraudAttempt │ │ └── scoring.py # Risk assessment logic │ │ │ └── marketplace/ │ ├── models.py # CommissionPlan, VendorBalance │ └── settlements.py # Payout processing

