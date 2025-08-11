# scripts/01_load_clean.R
# Importación y depuración (rutas relativas)

# --- Paquetes ----
req <- c("readr","dplyr")
inst <- setdiff(req, rownames(installed.packages()))
if (length(inst)) install.packages(inst)
library(readr); library(dplyr)

# --- Rutas ----
in_file  <- file.path("data", "tfr_gapminder.csv")
out_file <- file.path("data", "tfr_gapminder.rds")

if (!file.exists(in_file)) {
  stop("No se encontró 'data/tfr_gapminder.csv'. Súbelo a esa carpeta y vuelve a ejecutar.")
}

# --- Leer CSV ----
raw <- read_csv(in_file, show_col_types = FALSE)

# --- Limpieza mínima ----
# Nos quedamos con lo esencial y garantizamos tipos
tfr <- raw %>%
  rename_with(identity) %>%                 # (no cambia nombres; por claridad)
  filter(!is.na(country), !is.na(year)) %>%
  mutate(tfr = as.double(tfr)) %>%
  filter(!is.na(tfr)) %>%
  group_by(country, year) %>%               # si hubiera duplicados por país-año
  summarise(tfr = mean(tfr, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    decade  = (year %/% 10) * 10,
    tfr_cat = cut(
      tfr,
      breaks = c(-Inf, 2.1, 4, Inf),
      labels = c("≤2.1 (reemplazo)", "2.1–4", ">4"),
      right = TRUE,
      ordered_result = TRUE
    )
  ) %>%
  arrange(country, year)

# --- Guardar ----
saveRDS(tfr, out_file)
message("OK: datos limpios guardados en ", out_file)

# --- Chequeo rápido en consola cuando lo ejecutes en R:
# df <- readRDS('data/tfr_gapminder.rds'); dplyr::glimpse(df)
