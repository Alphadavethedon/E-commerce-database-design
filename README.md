
---

# 🛍️ Afrishop Connect E-Commerce Database System

A multi-tenant, scalable e-commerce platform tailored for African markets — combining global e-commerce standards with localized innovations such as mobile-first payments, last-mile agent delivery, and AI-powered marketplace features.

> Designed to grow from a student capstone project into a fully monetizable commercial SaaS platform.

---

## 🌍 Project Vision

Afrishop Connect aims to:

- 🧾 **Enable localized commerce** with mobile money (M-Pesa, Airtel Money, BNPL)
- 🚚 **Support agent-driven delivery** across hard-to-reach areas
- 🤖 **Use AI/ML for fraud detection and personalized recommendations**
- 💸 **Monetize via SaaS models** including commissions, vendor subscriptions, and ad placement

---

## 🧱 Core Tech Stack

| Layer       | Technologies                                                                 |
|-------------|-------------------------------------------------------------------------------|
| Backend     | Django, Django REST Framework, Celery, PostgreSQL (partitioned)              |
| Frontend    | HTML/CSS/JavaScript (Phase 1), React + Tailwind CSS (Phase 2)                |
| Payments    | Stripe (Test), M-Pesa API, Flutterwave, PesaPal                              |
| AI/ML       | Scikit-learn, TensorFlow                                                     |
| DevOps      | Docker, GitHub Actions, AWS/GCP (Phase 2)                                    |
| Analytics   | Metabase, Materialized Views                                                 |

---

## 🛒 Core Features

- 🏬 Multi-vendor marketplace with tenant isolation
- 📱 Mobile-first checkout flow (simulated with Stripe test payments)
- 🧑‍💼 Vendor onboarding and admin dashboards
- 📈 Basic analytics: sales & inventory tracking

---

## 🎯 Deliverables

- ✅ Full Django codebase (well-documented)
- 🧠 ERD & schema (SQL + Mermaid diagram)
- 🎥 Demo video + deployed prototype (e.g., Vercel/Heroku)
- 🔜 **Phase 2**: Transition to full commercial deployment

---

## 💰 Monetization Strategy

- **Localized Payment Support**:
  - M-Pesa, Airtel Money, Flutterwave, PesaPal
  - Buy Now, Pay Later (BNPL) integrations

- **Delivery Integrations**:
  - Sendy API, Pickup Mtaani

- **SaaS Features**:
  - Dynamic commissions by vendor tier
  - Subscription plans: Starter, Pro, Enterprise
  - Brand-sponsored ad marketplace

---

## 🌍 Africa-Specific Innovations

- 📞 **USSD order tracking**
- 💬 **WhatsApp Commerce Integration**
- 🧍 **Agent network onboarding & management**

---

## 📊 ERD Preview

[![ERD Diagram](./ERD/diagram.png)](https://www.mermaidchart.com/raw/ad6f6e38-669a-4f07-964d-a6cfda96d182?theme=light&version=v0.1&format=svg)

> [🖼️ View ERD in MermaidChart](https://www.mermaidchart.com/app/projects/c29cd0e2-b502-4b05-b812-d1e0433c630a/diagrams/ad6f6e38-669a-4f07-964d-a6cfda96d182/version/v0.1/edit)

---

## 🐳 Docker Setup

```bash
git clone https://github.com/Alphadavethedon/E-commerce-database-design.git
cd E-commerce-database-design
docker-compose up --build
```

---

## 🗂️ Directory Overview

```bash
ecommerce_project/
├── apps/
│   ├── multi_tenant/
│   │   ├── models.py          # Tenant model and isolation logic
│   │   └── middleware.py      # Tenant identification via request
│
│   ├── payments/
│   │   ├── models.py          # PaymentTransaction, Gateways
│   │   ├── mpesa.py           # M-Pesa Integration
│   │   └── flutterwave.py     # Flutterwave Integration
│
│   ├── fulfillment/
│   │   ├── models.py          # Delivery zones, pickup stations
│   │   └── sendy_integration.py
│
│   ├── ai/
│   │   ├── models.py          # Recommender model definitions
│   │   └── recommenders.py    # Personalized product suggestions
│
│   ├── risk/
│   │   ├── models.py          # FraudRule, FraudAttempt
│   │   └── scoring.py         # Risk scoring logic
│
│   └── marketplace/
│       ├── models.py          # Commission plans, balances
│       └── settlements.py     # Vendor payouts
```

---

## 🚧 Phase 2 Goals

- 🌐 React + Tailwind frontend with dynamic checkout
- 🔐 OAuth2 support for vendors and agents
- 📲 WhatsApp bot for vendor/agent coordination
- 🛰️ Host on AWS or GCP with CI/CD (GitHub Actions)
- 📦 Package for SaaS distribution

---

## 🤝 Contributions Welcome

We’re building for Africa, by Africa. If you’d like to contribute:

1. Fork the repo
2. Create a feature branch
3. Submit a pull request

Open to contributors interested in:
- Django backend optimization
- M-Pesa & Flutterwave payment testing
- React frontend (Phase 2)

---

## 👤 Maintainer

**Davis Wabwile**  
Full-Stack Engineer | Open Source Contributor | Cloud & DevOps  
- 🌍 [Portfolio](https://alphadavethedon.github.io/Davis-portfolio/)  
- 🐙 [GitHub](https://github.com/Alphadavethedon)  
- 💼 [LinkedIn](https://linkedin.com/in/daviswabwile)  
- 📝 [Medium](https://medium.com/@daviswabwile)

---
