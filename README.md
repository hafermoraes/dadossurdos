
# Análises de suporte para a Caracterização demográfica da População Surda Brasileira

Este repositório contém os código de extração e preparação dos dados sobre a população surda brasileira provenientes das fontes oficiais como 
- Edição 2000 do Censo Demográfico
- Edição 2010 do Censo Demográfico
- Edição 2013 e 2019 da Pesquisa Nacional de Saúde (PNS)
- Edição 2022/3ºTrimestre da Pesquisa Nacional de Amostra pr Domicílios - Contínua (PNADC)

O repositório também contempla os scripts de análise para a caracterização demográfica da população surda brasileira através 
- da componente demográfica da migração, 
- da componente demográfica da fecundidade 
- da componente demográfica da mortalidade
- do arranjo domiciliar
- do modelo preditivo Libras
- da análise espacial da população surda no país

## 🐳 Ambiente de Desenvolvimento Docker

Este projeto disponibiliza uma imagem pronta com todo o ambiente configurado (Tidyverse, TeX Live e dados do IBGE pré-processados).

Para baixar o ambiente localmente, execute:

```bash
docker pull ghcr.io/hafermoraes/dadossurdos:latest
```

e em seguida

```bash
	docker run -it --rm \
		--detach \
		--publish 8787:8787 \
		--env DISABLE_AUTH=true \
		dadossurdos
```

Agora abra qualquer navegador e acesse http://localhost:8787
