# Extra Instructions

Rules the LLM follows when it writes SQL for `listings`.

- `price` is the nightly price in U.S. dollars. When the user asks what something costs, use `price` and round money to whole dollars in the answer.
- `host_is_superhost` and `instant_bookable` are stored as text values `'t'` and `'f'`, not SQL booleans. Use those exact text values when filtering.
- When the user names a city, match against the `city` column using the dataset values `Chicago`, `Columbus`, or `Twin Cities`.
- When averaging `review_scores_rating`, exclude rows where `review_scores_rating` is `NULL`.
- When searching listing names, use a case-insensitive match so capitalization does not affect the result.
