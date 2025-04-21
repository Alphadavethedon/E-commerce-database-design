# 🛍️ AFRISHOP CONNECT E-Commerce Database System

 └──   Project Vision
Build a scalable, multi-tenant e-commerce platform tailored for African markets, combining global standards with local innovations like:
Mobile-first payments (M-Pesa, Airtel Money, BNPL)
Agent-driven last-mile delivery
AI-powered marketplace tools
Designed for SaaS monetization (subscriptions, transaction fees, ads) and gradual scalability from school project to commercial deployment.

└──     Core Tech Stack


Layer	Tools
Backend	Django (Python), Django REST Framework, Celery, PostgreSQL (with partitioning)
Frontend	HTML/CSS/JS (Phase 1), React (Phase 2), Tailwind CSS
Payments	Stripe (test), M-Pesa API, Flutterwave, PesaPal
AI/ML	Python (scikit-learn, TensorFlow) for recommendations/fraud detection
DevOps	Docker, AWS/GCP (Phase 2), GitHub Actions
Analytics	Metabase (open-source BI), Materialized Views




└──        Core Features
Multi-vendor marketplace with tenant isolation
Mobile-optimized checkout (test payments via Stripe)
Vendor onboarding & admin dashboards
Basic analytics (sales, inventory)

└──       Deliverables

Full Django codebase + documentation
ERD & schema design (SQL + Mermaid)
Demo video + hosted prototype (Vercel/Heroku)
Phase 2: Commercial Product (Post-Graduation)

└──     Monetization Ready
Localized Payments: M-Pesa, Airtel Money, BNPL
Delivery Integrations: Sendy, Pickup Mtaani APIs
SaaS Features:
Dynamic commission models
Vendor subscriptions (starter/pro/enterprise)
Ad marketplace for brands
Africa-Specific Innovations
USSD order tracking
WhatsApp Commerce integration
Agent network management




## 📊 ERD Preview
[![ERD](./ERD/diagram.png)
](https://www.mermaidchart.com/raw/ad6f6e38-669a-4f07-964d-a6cfda96d182?theme=light&version=v0.1&format=svg)
![image](https://github.com/user-attachments/assets/4e2eb7f8-0f99-4035-8e48-9106631efb89)

https://www.mermaidchart.com/app/projects/c29cd0e2-b502-4b05-b812-d1e0433c630a/diagrams/ad6f6e38-669a-4f07-964d-a6cfda96d182/version/v0.1/edit

## 🐳 Docker Setup
```bash
docker-compose up

ecommerce_project/ ├── apps/ │ ├── multi_tenant/ │ │ ├── models.py # Tenant model with custom settings │ │ └── middleware.py # Tenant identification middleware │ │ │ ├── payments/ │ │ ├── models.py # PaymentTransaction, Gateway │ │ ├── mpesa.py # M-Pesa integration │ │ └── flutterwave.py # Flutterwave integration │ │ │ ├── fulfillment/ │ │ ├── models.py # DeliveryZone, PickupStation │ │ └── sendy_integration.py │ │ │ ├── ai/ │ │ ├── models.py # Recommendation models │ │ └── recommenders.py # ML recommendation logic │ │ │ ├── risk/ │ │ ├── models.py # FraudRule, FraudAttempt │ │ └── scoring.py # Risk assessment logic │ │ │ └── marketplace/ │ ├── models.py # CommissionPlan, VendorBalance │ └── settlements.py # Payout processing

