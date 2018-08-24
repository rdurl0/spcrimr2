library(tidyverse)


#
y_labs <- as.character(c(seq(2500, 0, -250), seq(250, 2500, 250)))
x_labs <- c(paste(seq(0, 70, by=5), "até", seq(4, 74, by=5)), "75 e mais")

#
faixa_etaria <- tibble(faixa_etaria = rep(x_labs, 39), id = rep(seq(1,16), 39)) %>%
  arrange(id)
faixa_etaria <- bind_rows(faixa_etaria, faixa_etaria) %>% select(faixa_etaria)
faixa_etaria

#
faixa_etaria <- seade %>%
  select(ano, V5:V20, V22:V37) %>% 
  group_by(ano) %>%
  summarise_all(sum, na.rm = TRUE) %>%
  gather(key = ano, value = populacao) %>%
  rename(cod = ano) %>%
  mutate(genero = as.factor(c(rep("Masculina", 624), rep("Feminina", 624))),
         faixa_etaria = faixa_etaria$faixa_etaria,
         ano = rep(year(seq(as.POSIXct("1980-01-01"), by = "year", length.out = 39)), 32),
         cod = as.factor(cod))