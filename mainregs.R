library(tidyverse)
library(janitor)
library(sf)
library(lubridate)
library(readxl)
library(stringi)
library(sandwich)
library(lmtest)
library(ggrepel)

normaliza_nombre <- function(x) {
  x |> 
    str_to_upper() |>
    str_squish() |>
    stringi::stri_trans_general("Latin-ASCII")
}

# LISTINGS
listings <- read_csv('listings.csv') |>
  clean_names()

# LISTINGS SCRAPED (no usado aún pero cargado)
listings_scraped <- read_csv('listings_scrapped.csv') |>
  clean_names()

# REVIEWS
reviews <- read_csv('reviews1.csv') |>
  clean_names()

# GEOMETRÍA DE ALCALDÍAS
neighbourhoods <- st_read('neighbourhoods.geojson') |>
  clean_names()

# DELITOS
delitos_mun <- read_excel('municipal Delitos - OCTUBRE 2025.xlsx') |>
  clean_names()

listings <- listings |>
  mutate(
    price_num = price |>
      str_remove_all("[$,]") |>
      as.numeric()
  ) |>
  filter(room_type == "Entire home/apt")

reviews_por_listing <- reviews |>
  count(listing_id, name = "n_reviews")

listings <- listings |>
  left_join(reviews_por_listing, by = c("id" = "listing_id")) |>
  mutate(
    n_reviews_total = coalesce(n_reviews, number_of_reviews)
  )
# 7.1 Normalizar nombres en neighbourhoods
# → checa nombres reales; ajustar si se llama distinto
neighbourhoods_clean <- neighbourhoods |>
  mutate(
    alcaldia = normaliza_nombre(neighbourhood)
  ) |>
  st_drop_geometry() |>
  select(alcaldia) |>
  distinct()

# 7.2 Normalizar nombres en listings
listings <- listings |>
  mutate(
    alcaldia = normaliza_nombre(neighbourhood)
  )


### 8. LIMPIAR BASE DE DELITOS -----------------------------

# Mira cómo quedaron los nombres después de clean_names()
names(delitos_mun)

# Construimos variables para 2025
delitos_mun <- delitos_mun |>
  mutate(
    alcaldia       = normaliza_nombre(municipio),
    delitos_totales = x2025,        # columna "2025" del Excel
    delitos_km2     = ratio_2025    # columna "RATIO 2025" del Excel
  ) |>
  select(
    alcaldia,
    delitos_totales,
    delitos_km2
  )

### 9. UNIR LISTINGS + DELITOS ------------------------------

listings_full <- listings |>
  left_join(delitos_mun, by = "alcaldia")




listings_full <- listings_full %>%
  left_join(
    listings_scraped %>% select(id, estimated_revenue_l365d), 
    by = "id"
  )

model_price <- lm(price ~ delitos_km2, data = listings_full)

# View results
summary(model_price)
# We cluster by 'alcaldia' because that is the level where icpth repeats.
robust_results <- coeftest(model_price, 
                           vcov = vcovCL(model_price, cluster = ~alcaldia))

# 4. Compare
print(robust_results)



model_revenue <- lm(estimated_revenue_l365d ~ delitos_km2, data = listings_full)

# View results
summary(model_revenue)


data_ingresos <- read_csv('estimado_ingresos.csv')
keys_ingresos <- read_csv('mun_keys_ingresos.csv')
keys_ingresos <- keys_ingresos |>
  filter(cve_ent==9) |>
  mutate(alcaldia=normaliza_nombre(descrip)) |>
  select(cve_mun, alcaldia) 
data_ingresos <- data_ingresos |>
  filter(ent==9, est==1)

data_ingresos <- data_ingresos |>
  left_join(keys_ingresos, by = c("mun" = "cve_mun"))


###listings + income
listings_full <- listings_full |>
  left_join(data_ingresos, by = "alcaldia")

###new reg
model_price <- lm(price ~ delitos_km2 + icpth, data = listings_full)
summary(model_price)

model_revenue <- lm(estimated_revenue_l365d ~ delitos_km2 + icpth, data = listings_full)

# View results
summary(model_revenue)

# 3. Calculate Clustered Standard Errors
# We cluster by 'alcaldia' because that is the level where icpth repeats.
robust_results <- coeftest(model_price, 
                           vcov = vcovCL(model_price, cluster = ~alcaldia))

# 4. Compare
print(robust_results)


### 10. AGREGAR A NIVEL ALCALDÍA ----------------------------

alcaldia_stats <- listings_full |>
  group_by(alcaldia) |>
  summarise(
    n_listings          = n(),
    mean_price          = mean(price_num, na.rm = TRUE),
    median_price        = median(price_num, na.rm = TRUE),
    avg_reviews         = mean(n_reviews_total, na.rm = TRUE),
    delitos_km2         = first(delitos_km2),
    delitos_totales     = first(delitos_totales),
    ingresos            = first(icpth)
  ) |>
  ungroup()


ggplot(alcaldia_stats, aes(x = delitos_km2, y = ingresos)) +
  # 1. The Regression Line (Shaded area = Confidence Interval)
  geom_smooth(method = "lm", color = "red", fill = "lightpink", alpha = 0.3) +
  
  # 2. The Points
  geom_point(size = 3, color = "darkblue") +
  
  # 3. The Labels (Assumes you have a column named 'alcaldia')
  geom_text_repel(aes(label = alcaldia), size = 3.5) +
  
  # 4. Formatting
  theme_minimal() +
  labs(
    title = "Relationship between Income and Crime Density",
    subtitle = "Analysis at Alcaldia Level",
    x = "Crimes per km²",
    y = "Average Income"
  )
