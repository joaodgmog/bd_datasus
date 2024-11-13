library("tidyverse")


# Dado original
dados <- read_rds("dados/SINASC2015120249.rds")

colnames(dados)
sinasc <- dados |> select(DTNASC, CODMUNNASC, CONSULTAS)
nrow(sinasc)

# salvando csv
write.csv(sinasc,"dados/sinasc_red.csv")

sinasc_ <- sinasc |> transmute(
  CODMUNNASC,
  ANO = lubridate::year(DTNASC),
  MES = lubridate::month(DTNASC),
  CONSULTAS )

# salvando csv
write_csv2(sinasc_,"dados/sinasc_2015_2024.csv")

# salvando em disco
sinasc_agrupado <- sinasc_ |> group_by(CODMUNNASC, ANO, MES, CONSULTAS) |> summarise(Total = n())
write_csv2(sinasc_agrupado,"dados/csv/sinasc_agrupado.csv")
