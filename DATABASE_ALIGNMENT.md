# Sam Solar — Database alignment (final)

The application is aligned with the agreed 12 core tables:
`addresses`, `cart_items`, `categories`, `customers`, `favorites`, `notifications`, `order_items`, `orders`, `product_images`, `products`, `search_history`, `suppliers`.

Additional tables required by implemented application behavior:
- `offers`: the offers feature needs its own old price and offer price, independent of `products.price`.
- `admin_roles`: secure Supabase RLS needs a server-side admin role source; this avoids the obsolete `users` table.

Important alignment decisions:
- All primary/foreign keys are UUIDs.
- Customer-owned records use `user_id = auth.users.id`.
- Products use the agreed Arabic column names (`name_ar`, `description_ar`, `image_url`, `brand_ar`, `specifications_ar`, `warranty_ar`) and supplier/category foreign keys.
- Product gallery is represented by `product_images` rather than a legacy `gallery` column.
- Ready integrated systems are normal products assigned to the `المنظومات الجاهزة` category; there is no `ready_systems` table.
- Offers are shown only when active and inside their start/end dates.
- Ratings/reviews are not used as a product-rating feature.
