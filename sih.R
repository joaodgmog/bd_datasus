# Carrega o pacote tidyverse, que inclui dplyr, stringr e outras ferramentas úteis para manipulação de dados
library("tidyverse")

# Carrega o conjunto de dados SIH (Sistema de Informações Hospitalares) de 2015 a 2024
sih <- readRDS("dados/SIH_2015_2024.rds")

# Filtra para excluir registros cujos diagnósticos principais (DIAG_PRINC) começam com "O" (excluindo partos)
sih_sem_partos <- sih %>% 
  filter(!str_detect(DIAG_PRINC, "^O"))

# Agrupa os dados restantes por ano, mês, município de residência e diagnóstico principal (DIAG_PRINC)
# e calcula o total de ocorrências por grupo
sih_sem_partos <- sih_sem_partos |> 
  group_by(ANO_CMPT, MES_CMPT, MUNIC_RES, DIAG_PRINC) |> 
  summarise(Total = n(), .groups = "drop")  # .groups = "drop" remove o agrupamento automaticamente

# Salva o dataset com diagnósticos principais excluindo partos, mantendo DIAG_PRINC para futuras análises
# saveRDS(sih_sem_partos,"dados/sih_sem_partos_diag.rds")

# Agrupa o dataset `sih_sem_partos` por ano, mês e município de residência para obter o total de internações excluindo partos
sih_agrupado <- sih_sem_partos |> 
  group_by(ANO_CMPT, MES_CMPT, MUNIC_RES) |> 
  summarise(Total = sum(Total), .groups = "drop")  # Utiliza `sum(Total)` para evitar duplicar a contagem de n()

# Salva o resultado em disco em formato .rds para reuso futuro e como CSV para fácil visualização
saveRDS(sih_agrupado,"dados/sih_agrupado.rds")
write_csv2(sih_agrupado, "dados/csv/sih_agrupado.csv")

# Define a lista de códigos ICSAP (Internações por Condições Sensíveis à Atenção Primária)
icsap <- c("A00", "A01", "A02", "A03", "A04", "A05", "A06", "A07", "A08", "A09", 
           "A15", "A16", "A17", "A18", "A19", "A33", "A34", "A35", "A36", "A37", 
           "A50", "A51", "A52", "A53", "A95", "B05", "B06", "B16", "B26", "B50", 
           "B51", "B52", "B53", "B54", "B77", "D50", "E10", "E11", "E12", "E13", 
           "E14", "E50", "E51", "E52", "E53", "E54", "E55", "E56", "E58", "E59", 
           "E60", "E61", "E63", "E64", "E86", "G00", "G40", "H66", "I02", "I11", 
           "I20", "I50", "J01", "J02", "J03", "J06", "J15", "J18", "J21", "J31", 
           "J42", "J45", "K25", "K26", "K27", "K28", "K92", "L08", "N30", "N34", 
           "N39", "O23", "P35")

# Cria uma expressão regex para capturar qualquer diagnóstico que comece com um dos códigos ICSAP definidos
regex_icsap <- paste0("^(", paste(icsap, collapse = "|"), ")") 

# Filtra o dataset original `sih` para incluir apenas diagnósticos que começam com os códigos ICSAP
sih_icsap <- sih[grepl(regex_icsap, sih$DIAG_PRINC), ]

# Salva o dataset filtrado contendo apenas diagnósticos ICSAP para futuras análises
saveRDS(sih_icsap, "dados/sih_icsap.rds")
write_csv2(sih_icsap, "dados/sih_icsap.csv")

# Agrupa o dataset `sih_icsap` por ano, mês e município de residência para obter o total de internações ICSAP
sih_icsap_agrupado <- sih_icsap |> 
  group_by(ANO_CMPT, MES_CMPT, MUNIC_RES) |> 
  summarise(Total = n(), .groups = "drop")

# Salva o resultado agrupado em formato CSV para facilitar a visualização e análise
write_csv2(sih_icsap_agrupado, "dados/csv/sih_icsap_agrupado.csv")
