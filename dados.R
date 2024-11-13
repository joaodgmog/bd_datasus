## Instalação dos pacotes necessários
# Descomente as linhas abaixo para instalar os pacotes uma única vez

# install.packages("remotes")
# install.packages("tidyverse")
# install.packages("data.table")
# install.packages("devtools")
# devtools::install_github("danicat/read.dbc", force = TRUE)  # Para ler arquivos .dbc
# remotes::install_github("rfsaldanha/microdatasus", force = TRUE)  # Pacote para baixar dados do DATASUS

# Carrega os pacotes necessários
library("remotes")
library("tidyverse")
library("data.table")
library("microdatasus")

# Função para baixar, processar e salvar dados do DATASUS
baixar_arquivos <- function(sistema, year_start, month_start, year_end, month_end) {
  # Baixa os dados do sistema especificado e intervalo de tempo para Pernambuco (uf = "PE")
  dados <<- fetch_datasus(
    year_start = year_start,
    month_start = month_start,
    year_end = year_end,
    month_end = month_end,
    uf = "PE",
    information_system = sistema
  )
  
  # Processa os dados baixados de acordo com o sistema de origem
  dados <<- if (sistema == "SIH-RD") {
    process_sih(dados)
  } else if (sistema == "SIM-DO") {
    process_sim(dados)
  } else if (sistema == "SINASC") {
    process_sinasc(dados)
  } else {
    process_sia(dados)
  }
  
  # Define o caminho e o nome do arquivo para salvar os dados
  caminho <- paste0("dados/", sistema, year_start, month_start, year_end, month_end)
  
  # Salva os dados em formato .rds para uso futuro
  saveRDS(dados, paste0(caminho, ".rds"))
  
  # Se necessário, descomente a linha abaixo para salvar em formato .csv
  # write.csv2(dados, paste0(caminho, ".csv"))
}

# Chamadas da função para baixar e processar dados de diferentes sistemas do DATASUS



# =============== ATENÇÃO =============== → Digitar a janela de tempo desejada

# Sistema de Nascidos Vivos (SINASC) de Janeiro de 2015 a Setembro de 2024
baixar_arquivos("SINASC", 2015, 1, 2024, 9)

# Sistema de Mortalidade (SIM-DO) de Janeiro de 2015 a Setembro de 2024
baixar_arquivos("SIM-DO", 2015, 1, 2024, 9)

# Sistema de Informações Hospitalares (SIH-RD) de Janeiro de 2021 a Outubro de 2024
baixar_arquivos("SIH-RD", 2021, 1, 2024, 10)

# Sistema de Informações Ambulatoriais (SIA-PA) de Janeiro de 2015 a Dezembro de 2020
baixar_arquivos("SIA-PA", 2015, 1, 2020, 12)

# Remove o objeto 'dados' do ambiente de trabalho para liberar memória
rm(dados)
