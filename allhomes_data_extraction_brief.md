# Allhomes data extraction brief

## Overview

The `allhomes` R package extracts historical sales data from the Australian property website Allhomes.com.au. Starting with version 0.4.0, the package uses Allhomes' Apollo GraphQL API instead of scraping static HTML pages, as Allhomes shifted to dynamic data loading. This approach queries the `/graphql` endpoint for structured JSON responses, improving data access. The package relies on `httr2` for HTTP requests and `tidyverse` for data manipulation.

## Process

Data extraction involves sending a GraphQL query to Allhomes' API. Key inputs include the suburb slug (in a specific format like "suburb-state-postcode"), year (optional), and pagination parameters. The API returns sales records in JSON, which the package processes into a tidy data frame. Users interact via `get_past_sales_data()`, which handles the query and formatting internally.

## Key components

- **Persisted queries**: The package uses a predefined GraphQL query identified by a SHA256 hash. This hash ensures the server recognises the query but can change server-side, potentially breaking requests.
- **Variables**: Queries include locality (suburb slug and type), filters (e.g., minimum bedrooms/bathrooms), duration (specific year or all history), sorting (by sale age), and pagination (page number and size).
- **Request structure**: A GET request to `/graphql` with operation name, JSON-encoded variables, and extensions (including the hash). Headers specify the operation for proper routing.

## Limitations

Reliability depends on the SHA256 hash remaining unchanged; if Allhomes updates it server-side, requests will fail, requiring package updates. Data is fetched in a single request with a default limit of 5000 records, which may truncate results for high-volume suburbs. Users can increase the limit via `get_past_sales_data()`, and the function warns if records match the limit. Updates via pull requests are welcome to address such issues.
