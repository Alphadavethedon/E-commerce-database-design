## GraphQL Query Examples

```graphql
query GetProductWithVariants($id: ID!) {
  product(id: $id) {
    name
    description
    variants {
      sku
      price
      attributes {
        name
        value
      }
    }
    media {
      url
      type
    }
  }
}