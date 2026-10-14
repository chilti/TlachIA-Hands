---
name: openalex-mexico-visualizer
description: Generador de artefactos visuales interactivos y dashboards analíticos (HTML con Plotly.js, Redes PyVis y Tarjetas PNG) a partir de los datos cienciométricos extraídos por las skills del ecosistema OpenAlex México.
dependencies:
  - python: "/home/ambientesPy/revistaslatam"
  - script: "scripts/openalex_visualizer_cli.py"
---

# OpenAlex México Visualizer

Capa de presentación y motor de generación de artefactos visuales interactivos para la producción científica mexicana.

## Overview

Transforma los resultados analíticos en formato JSON generados por las skills de datos (`openalex-mexico-aggregations`, `openalex-mexico-semantic-search`, `openalex-mexico-works-search`, etc.) en:
1. **Dashboards Ejecutivos HTML:** Archivos autocontenidos con tarjetas de KPIs, gráficos interactivos de Plotly.js y tablas dinámicas listos para el panel de vista previa.
2. **Series Temporales Duales:** Publicaciones anuales combinadas con la evolución cronológica del FWCI relativo al benchmark mundial (1.00).
3. **Donuts de Acceso Abierto:** Distribución de las 6 modalidades (Diamante vs Comercial) y cuantificación del gasto en APC.
4. **Rankings de Capacidad:** Barras horizontales interactivas con desambiguación y banderas de afiliación mexicana.
5. **Tarjetas Estáticas PNG:** Gráficas compactas listas para incrustarse directamente en el chat.

## Dependencies

- **Entorno Python:** `/home/ambientesPy/revistaslatam`
- **Script CLI:** [`scripts/openalex_visualizer_cli.py`](file:///mnt/expansion/desplegados/sos-mcp-services/.agents/skills/openalex-mexico-clickhouse/openalex-mexico-visualizer/scripts/openalex_visualizer_cli.py)
- **Librerías principales:** `plotly`, `matplotlib`, `pyvis`

## CLI Interface

### 1. Generación Automática (Detección Inteligente)
El visualizador detecta la estructura interna del JSON (`top_entities`, `grouped_by`, `works`, etc.) y renderiza el artefacto correspondiente:
```bash
/home/ambientesPy/revistaslatam/bin/python scripts/openalex_visualizer_cli.py \
  --input /ruta/a/datos.json \
  --title "Análisis Cienciométrico de Litio en México" \
  --output /ruta/a/artefacto_interactivo.html \
  --png /ruta/a/tarjeta_chat.png
```

### 2. Forzar un Tipo de Visualización Específico
Tipos disponibles (`--type`):
- `top-ranking`: Para listas de autores o instituciones ordenadas por impacto o producción.
- `timeseries`: Para series temporales anuales con línea dual de FWCI y publicaciones.
- `oa-donut`: Para gráficos de proporción de vías de Acceso Abierto y gasto APC en USD.
- `dossier-works`: Para catálogos de publicaciones con desglose de coautoría internacional.
- `network`: Para redes interactivas de colaboración científica.

```bash
/home/ambientesPy/revistaslatam/bin/python scripts/openalex_visualizer_cli.py \
  --input /ruta/a/agregacion_oa.json \
  --type oa-donut \
  --title "Distribución de Acceso Abierto y Gasto en APC" \
  --output /ruta/a/reporte_oa.html
```

## Directrices para el Agente (LLM)

1. **Flujo en Dos Fases:**
   - **Fase 1 (Cómputo):** Obtén los datos crudos ejecutando la skill de datos idónea (`aggregations`, `semantic-search`, etc.) y guarda el resultado en `/tmp/datos.json` o en `workspace/`.
   - **Fase 2 (Visualización):** Invoca `openalex-mexico-visualizer` apuntando a dicho JSON para generar el archivo `.html`.
2. **Presentación de la Respuesta al Usuario:**
   - Proporciona tu resumen analítico cuantitativo en texto sobrio.
   - Si generaste una tarjeta PNG con `--png`, inclúyela en el chat: `![Gráfica](/ruta/a/tarjeta.png)`.
   - Ofrece el enlace clickable al artefacto interactivo completo: `[Abrir Dashboard Interactivo](file:///ruta/a/artefacto.html)`.
