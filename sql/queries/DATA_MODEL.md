## Architectural Decisions

### 1. Variant Management System
- **Parent-Child Relationship**: Products → Variants
- **Benefits**:
  - Clear inventory tracking per SKU
  - Flexible pricing per variant
  - Efficient stock management

### 2. Search Optimization
- `FULLTEXT` indexes for product search
- Slug fields for SEO-friendly URLs
- N-gram parser for Asian language support

### 3. Media Handling
- CDN-ready URL storage
- Support for 3D models and videos
- Prioritization system for display