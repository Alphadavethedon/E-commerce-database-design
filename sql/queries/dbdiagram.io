erDiagram
    %% ================ CORE TENANT STRUCTURE ================
    tenants ||--o{ customers : "1:N"
    tenants {
        int id PK
        varchar(100) name
        char(64) api_key UK
        enum plan
        decimal monthly_fee
        decimal transaction_fee
        char(3) default_currency
        varchar(50) timezone
        bool is_active
        enum onboarding_status
        json kyc_data
        timestamp created_at
        timestamp updated_at
    }
    
    customers {
        int id PK
        int tenant_id FK
        varchar(100) name
        varchar(100) email
        varchar(20) phone_number UK
        varchar(255) password
        json address
        bool is_verified
        enum verification_method
        tinyint credit_score
        int loyalty_points
        char(2) preferred_language
        json marketing_consent
        timestamp created_at
        datetime last_login
        varchar(255) device_fingerprint
    }
    
    %% ================ PRODUCT CATALOG ================
    tenants ||--o{ product_categories : "1:N"
    product_categories {
        int id PK
        int tenant_id FK
        varchar(100) name
        int parent_id FK
        varchar(255) image_url
        bool is_featured
        decimal commission_rate
        json seo_metadata
        json ai_tags
    }
    
    product_categories ||--o{ product_categories : "self-reference"
    product_categories ||--o{ products : "1:N"
    
    products {
        int id PK
        int tenant_id FK
        int category_id FK
        varchar(255) name
        text description
        decimal base_price
        decimal compare_at_price
        decimal cost_price
        bool is_active
        bool is_digital
        int delivery_profile_id
        int tax_profile_id
        json ai_recommendations
        timestamp created_at
        timestamp updated_at
    }
    
    %% ================ PAYMENTS & ORDERS ================
    payment_gateways {
        int id PK
        varchar(50) name
        json country_codes
        decimal processing_fee
        tinyint settlement_days
        bool is_active
        json config_schema
        varchar(255) webhook_url
    }
    
    
    payment_transactions ||--o{ payment_gateways : "N:1"
    payment_transactions {
        bigint id PK
        int tenant_id FK
        int customer_id FK
        int gateway_id FK
        decimal amount
        char(3) currency
        varchar(100) transaction_id UK
        varchar(20) phone_number
        enum status
        decimal fee_amount
        varchar(100) settlement_id
        json metadata
        timestamp created_at
        timestamp updated_at
    }
    
    orders ||--o{ order_items : "1:N"
    orders {
        int id PK
        int tenant_id FK
        int customer_id FK
        varchar(50) order_number UK
        enum status
        decimal subtotal
        decimal shipping_total
        decimal tax_total
        decimal discount_total
        decimal grand_total
        varchar(50) payment_method
        enum payment_status
        json shipping_address
        json billing_address
        text customer_note
        varchar(45) ip_address
        enum device_type
        timestamp created_at
        timestamp updated_at
    }
    
    order_items {
        int id PK
        int order_id FK
        int product_id FK
        int vendor_id FK
        int quantity
        decimal price
        decimal discount_amount
        decimal tax_amount
        decimal total_price
        enum fulfillment_status
    }
    
    %% ================ FULFILLMENT SYSTEM ================
    delivery_zones {
        int id PK
        int tenant_id FK
        varchar(100) name
        json polygon_coordinates
        decimal base_fee
        decimal fee_per_km
        tinyint estimated_days_min
        tinyint estimated_days_max
        bool is_active
    }
    
    pickup_stations {
        int id PK
        int tenant_id FK
        varchar(100) name
        point location
        json address
        varchar(20) contact_phone
        json operating_hours
        bool is_active
    }
    
    shipments ||--o{ shipment_items : "1:N"
    shipments {
        int id PK
        int order_id FK
        varchar(50) carrier
        varchar(100) tracking_number
        varchar(255) tracking_url
        enum status
        date estimated_delivery
        date actual_delivery
        decimal shipping_cost
        decimal package_weight
        varchar(50) package_dimensions
        timestamp created_at
        timestamp updated_at
    }
    
    shipment_items {
        int id PK
        int shipment_id FK
        int order_item_id FK
        int quantity
    }
    
    %% ================ VENDOR MANAGEMENT ================
    vendors {
        int id PK
        int tenant_id FK
        varchar(100) business_name
        varchar(100) contact_person
        varchar(20) phone
        varchar(100) email
        json bank_details
        enum tier
        decimal commission_rate
        bool is_approved
        json verification_data
        timestamp created_at
        timestamp updated_at
    }

    
    
    vendor_balance {
        int id PK
        int vendor_id FK
        decimal available_balance
        decimal pending_balance
        date last_payout_date
        date next_payout_date
    }
    
    %% ================ RELATIONSHIPS ================
    customers ||--o{ orders : "places"
    products ||--o{ order_items : "ordered_as"
    vendors ||--o{ order_items : "supplies"
    orders ||--o{ payment_transactions : "has"
    orders ||--o{ shipments : "fulfilled_by"
    vendors ||--o{ vendor_balance : "has"
    delivery_zones }|--|| tenants : "belongs_to"
    pickup_stations }|--|| tenants : "belongs_to"
