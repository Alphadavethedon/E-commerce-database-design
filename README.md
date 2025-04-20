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
[![ERD](./ERD/diagram.png)
](https://www.mermaidchart.com/raw/ad6f6e38-669a-4f07-964d-a6cfda96d182?theme=light&version=v0.1&format=svg)
![image](https://github.com/user-attachments/assets/4e2eb7f8-0f99-4035-8e48-9106631efb89)

https://www.mermaidchart.com/app/projects/c29cd0e2-b502-4b05-b812-d1e0433c630a/diagrams/ad6f6e38-669a-4f07-964d-a6cfda96d182/version/v0.1/edit

## 🐳 Docker Setup
```bash
docker-compose up

ecommerce_project/ ├── apps/ │ ├── multi_tenant/ │ │ ├── models.py # Tenant model with custom settings │ │ └── middleware.py # Tenant identification middleware │ │ │ ├── payments/ │ │ ├── models.py # PaymentTransaction, Gateway │ │ ├── mpesa.py # M-Pesa integration │ │ └── flutterwave.py # Flutterwave integration │ │ │ ├── fulfillment/ │ │ ├── models.py # DeliveryZone, PickupStation │ │ └── sendy_integration.py │ │ │ ├── ai/ │ │ ├── models.py # Recommendation models │ │ └── recommenders.py # ML recommendation logic │ │ │ ├── risk/ │ │ ├── models.py # FraudRule, FraudAttempt │ │ └── scoring.py # Risk assessment logic │ │ │ └── marketplace/ │ ├── models.py # CommissionPlan, VendorBalance │ └── settlements.py # Payout processing

