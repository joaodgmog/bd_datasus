library("tidyverse")

# Salva o conjunto de dados transformado em CSV para futuras análises
sim <- read.csv2("dados/SIM_2015_2024.csv")

# Carrega a lista de causas de morte evitáveis (código CE04)
att <- read.csv("dados/att.csv") |> pull(1)  # Lê e extrai a primeira coluna como vetor

# Filtra os dados para incluir apenas as causas de óbito evitáveis (presentes na lista ce04)
sim_att <- sim %>% filter(CAUSABAS %in% att)

# Salva o conjunto filtrado (mortes evitáveis) em disco, em formato RDS e CSV
saveRDS(sim_att, "dados/sim_att.rds")
write_csv2(sim_att, "dados/sim_att.csv")

# Agrupa os dados por Município, Ano e Mês e calcula o total de mortes para a faixa etária de 0 a 4 anos
sim_att_agrupado <- sim_att |> 
  group_by(CODMUNRES, ANO, MES) |> 
  summarise(Total = n(), .groups = "drop") # Agrupamento com contagem de casos

# Salva o conjunto de dados agrupado em CSV
write_csv2(sim_att_agrupado, "dados/csv/sim_att_agrupado.csv")
