# Midwest Airbnb Listings: Data Dictionary

**Dataset:** `listings` table in `midwest_airbnb.db` (SQLite), 14,887 rows and 29 columns
**Source:** Inside Airbnb (https://insideairbnb.com/get-the-data/), the detailed `listings.csv.gz` file for each of three regions: Chicago (snapshot 2026-07-20), Columbus (snapshot 2026-07-23), and Twin Cities MSA (snapshot 2026-07-21). Column meanings follow Inside Airbnb's data dictionary and assumptions (https://insideairbnb.com/data-assumptions/).
**Course:** ISA 401, Miami University

> One row is one listing that showed a nightly price on the snapshot date; listings with no price were dropped. Empty cells are stored as SQL `NULL`.

---

## Field Definitions

| Field | Type | Description |
|---|---|---|
| `city` | text | Which Inside Airbnb region the listing came from: `Chicago` (7,439 rows), `Columbus` (2,587), or `Twin Cities` (4,861). The Twin Cities file covers the Minneapolis-St. Paul metro area, not just the two cities. |
| `snapshot_date` | text | Date Inside Airbnb compiled the file, stored as an ISO text string, not a date: `2026-07-20` for Chicago, `2026-07-23` for Columbus, `2026-07-21` for Twin Cities. Every row of a city shares the same value. |
| `id` | text | Airbnb's listing id. Unique across the table (14,887 distinct values). Stored as text even though it looks numeric, so compare it to a quoted string. |
| `name` | text | Listing title as shown on Airbnb (for example "Tiny Studio Apartment 94 Walk Score"). Never empty. |
| `price` | real | Nightly price in U.S. dollars on the snapshot date, with the dollar sign and commas removed. Ranges from 2.56 to 11,412; never `NULL` (rows without a price were dropped). |
| `room_type` | text | Airbnb's four listing categories: `Entire home/apt` (11,652 rows), `Private room` (2,951), `Hotel room` (246), or `Shared room` (38). |
| `host_id` | text | Airbnb's unique identifier for the host. A host may appear on multiple listings. |
| `host_name` | text | Name of the host as displayed on Airbnb. May be `NULL` if unavailable. |
| `host_since` | text | Date the host first joined Airbnb, stored as an ISO-style text date. May be `NULL`. |
| `host_is_superhost` | text | Indicates whether the host was designated an Airbnb Superhost at the snapshot date. Typically `t` for true, `f` for false, or `NULL` if unavailable. |
| `neighbourhood` | text | Standardized neighbourhood assigned by Inside Airbnb. This field comes from Inside Airbnb's `neighbourhood_cleansed` column. |
| `latitude` | real | Latitude coordinate of the listing's location. |
| `longitude` | real | Longitude coordinate of the listing's location. |
| `property_type` | text | Airbnb's detailed description of the type of property, such as an entire rental unit, private room in a home, condo, or other accommodation type. |
| `accommodates` | integer | Maximum number of guests the listing is intended to accommodate. |
| `bedrooms` | real | Number of bedrooms reported for the listing. May be `NULL` when Airbnb does not provide a bedroom count. |
| `beds` | real | Number of beds reported for the listing. May be `NULL`. |
| `bathrooms_text` | text | Airbnb's text description of the bathroom count and type, such as `1 bath`, `2.5 baths`, or `1 shared bath`. |
| `minimum_nights` | integer | Minimum number of nights a guest must book for a stay under the listing's current minimum-night setting. |
| `availability_365` | integer | Number of days the listing is marked available during the next 365 days, from 0 to 365. An unavailable day should not automatically be interpreted as a booked day because hosts may block dates for other reasons. |
| `number_of_reviews` | integer | Total number of reviews associated with the listing as of the snapshot date. |
| `number_of_reviews_ltm` | integer | Number of reviews received by the listing during the last twelve months. |
| `first_review` | text | Date of the listing's earliest recorded review, stored as text. `NULL` for listings with no reviews. |
| `last_review` | text | Date of the listing's most recent recorded review, stored as text. `NULL` for listings with no reviews. |
| `review_scores_rating` | real | Overall guest review rating for the listing. May be `NULL` for listings without enough review information. |
| `reviews_per_month` | real | Average number of reviews the listing has received per month over its review history. May be `NULL` for listings with no reviews. |
| `instant_bookable` | text | Indicates whether the listing can be booked through Airbnb without the host manually approving the reservation first. Typically `t` for true or `f` for false. |
| `estimated_revenue_l365d` | real | Inside Airbnb's estimated listing revenue over the last 365 days, based on its methodology and assumptions rather than actual host-reported revenue. |
| `amenities_count` | integer | Number of individual amenities listed for the property. This field was computed for this course by counting the items in each listing's original Airbnb `amenities` list. |


Two hints: `neighbourhood` is Inside Airbnb's `neighbourhood_cleansed` column, and `amenities_count` is not an Inside Airbnb column; it was computed for this course as the number of items in each listing's `amenities` list. Everything else keeps its Inside Airbnb name, so the data dictionary linked above explains it.
