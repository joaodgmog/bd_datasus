# Carrega os pacotes tidyverse e lubridate para manipulação e transformação de dados
library("tidyverse")
library("lubridate")

# Carrega os dados do SIM (Sistema de Informações sobre Mortalidade)
dados <- read_rds("dados/SIM-DO2015120249.rds")

# Exibe os nomes das colunas disponíveis para referência
colnames(dados)

# Seleciona apenas as colunas de interesse: Data de Óbito, Código do Município, Idade e Causa Básica
sim <- dados |> 
  select(DTOBITO, CODMUNRES, IDADE, CAUSABAS)
nrow(sim)  # Exibe o número total de registros selecionados

# Processa e transforma os dados para extrair informações adicionais
sim_ <- sim |> transmute(
  CODMUNRES,
  ANO = year(DTOBITO),      # Extrai o ano da data de óbito
  MES = month(DTOBITO),     # Extrai o mês da data de óbito
  IDADE = case_when(
    as.numeric(str_sub(IDADE, 1, 1)) < 4 ~ 0,                        # Para idades menores que 4 (0-4 anos), define como 0
    as.numeric(str_sub(IDADE, 1, 1)) == 4 ~ as.numeric(str_sub(IDADE, 2, 3)), # Extrai idade para faixas etárias 5-99 anos
    TRUE ~ as.numeric(str_sub(IDADE, 2, 3)) + 100                    # Para idades >= 100, soma 100
  ),
  CAUSABAS = str_sub(CAUSABAS, 1, 3)  # Reduz o código da causa básica aos três primeiros caracteres
)

# Salva o conjunto de dados transformado em formato CSV
write_csv2(sim_, "dados/SIM_2015_2024.csv")

# Agrupa o conjunto de dados transformado por Município, Ano e Mês e calcula o total de óbitos
sim <- sim_ |> 
  group_by(CODMUNRES, ANO, MES) |> 
  summarise(Total = n(), .groups = "drop")  # .groups = "drop" remove o agrupamento residual
# Salva o conjunto agrupado em formato CSV
write_csv2(sim, "dados/csv/sim_agrupado.csv")

# ME 0 a 4 anos -----------------------------------------------------------

# Carrega a lista de causas de morte evitáveis do código CE04
ce04 <- read.csv("dados/ce04.csv") |> pull(1)  # Lê a primeira coluna do arquivo como vetor
# Filtra o conjunto de dados para incluir apenas causas de óbito evitáveis presentes na lista CE04
sim_ce04 <- sim_ %>% filter(CAUSABAS %in% ce04)

# Salva o conjunto filtrado em formato RDS e CSV para futuras análises
saveRDS(sim_ce04, "dados/sim_ce04.rds")
write_csv2(sim_ce04, "dados/sim_ce04.csv")

# Filtra o conjunto CE04 para incluir apenas registros de óbitos na faixa etária de 0 a 4 anos
sim_ce04_faixa <- sim_ce04 |> filter(IDADE < 5)

# Agrupa os dados CE04 por Município, Ano e Mês e calcula o total de óbitos na faixa etária de 0 a 4 anos
sim_ce04_agrupado <- sim_ce04_faixa |> 
  group_by(CODMUNRES, ANO, MES) |> 
  summarise(Total = n(), .groups = "drop")

# Salva o conjunto agrupado CE04 para a faixa etária de 0 a 4 anos em formato CSV
write_csv2(sim_ce04_agrupado, "dados/csv/sim_ce04_agrupado.csv")


# ME 5 a 74 anos -----------------------------------------------------------

# Carrega a lista de causas de morte evitáveis do código CE574
ce574 <- read.csv("dados/ce574.csv") |> pull(1)  # Lê a primeira coluna do arquivo como vetor

# Filtra o conjunto de dados para incluir apenas causas de óbito evitáveis presentes na lista CE574
sim_ce574 <- sim_ %>% filter(CAUSABAS %in% ce574)

# Salva o conjunto filtrado em formato RDS e CSV para futuras análises
saveRDS(sim_ce574, "dados/sim_ce574.rds")
write_csv2(sim_ce574, "dados/sim_ce574.csv")

# Filtra o conjunto CE574 para incluir apenas registros de óbitos na faixa etária de 5 a 74 anos
sim_ce574_faixa <- sim_ce574 |> filter(IDADE >= 5 & IDADE <= 74)

# Agrupa os dados CE574 por Município, Ano e Mês e calcula o total de óbitos na faixa etária de 5 a 74 anos
sim_ce574_agrupado <- sim_ce574_faixa |> 
  group_by(CODMUNRES, ANO, MES) |> 
  summarise(Total = n(), .groups = "drop")

# Salva o conjunto agrupado CE574 para a faixa etária de 5 a 74 anos em formato CSV
write_csv2(sim_ce574_agrupado, "dados/csv/sim_ce574_agrupado.csv")


# Infantil -----------------------------------------------------------

# Filtra o conjunto de dados para incluir apenas registros de óbitos infantis (idade < 1 ano)
sim_infantil <- sim_ |> filter(IDADE < 1)

# Agrupa os dados infantis por Município, Ano e Mês e calcula o total de óbitos infantis
sim_infantil_agrupado <- sim_infantil |> 
  group_by(CODMUNRES, ANO, MES) |> 
  summarise(Total = n(), .groups = "drop")

# Salva o conjunto agrupado infantil em formato CSV
write_csv2(sim_infantil_agrupado, "dados/csv/sim_infantil_agrupado.csv")


