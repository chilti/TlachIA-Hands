# Plan Maestro de Implementación de Artefactos Visuales e Interactivos para el Ecosistema TlachIA-Hands

**Fecha:** Octubre 2026  
**Ecosistema:** TlachIA-Hands · SinapsisAI · knoMap · sos-mcp-services · OpenAlex México  
**Entorno Python:** `/home/ambientesPy/revistaslatam`  
**Autoría:** Laboratorio de Inteligencia Científica y Cienciometría Computacional (UNAM / Antigravity)

---

## 1. Resumen Ejecutivo y Marco Arquitectónico

El presente documento define la arquitectura, catálogo técnico y fases de implementación de los **Artefactos Visuales e Interactivos** que capacitan al agente de IA (TlachIA-Hands / OpenHands con el modelo local de 20B) para presentar diagnósticos cienciométricos de nivel ejecutivo sin saturar su ventana de contexto.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        ARQUITECTURA DESACOPLADA DE ARTEFACTOS                          │
├─────────────────────────────────┬──────────────────────────────────────────────────────┤
│ CAPA 1: DATOS Y CÓMPUTO         │ Skills 1 a 6 (ClickHouse, LM Studio Nomics 768d, SNII)│
│                                 │ • openalex-mexico-aggregations                       │
│                                 │ • openalex-mexico-works-search                       │
│                                 │ • openalex-mexico-author-search                      │
│                                 │ • openalex-mexico-institutions                       │
│                                 │ • openalex-mexico-semantic-search                    │
│                                 │ • openalex-mexico-query-architect                    │
│                                 │ └── Generan: resultado.json (CERO JOINs)             │
├─────────────────────────────────┼──────────────────────────────────────────────────────┤
│ CAPA 2: MOTOR DE PRESENTACIÓN   │ 7ª Skill: openalex-mexico-visualizer                 │
│                                 │ └── Recibe: resultado.json                           │
├─────────────────────────────────┼──────────────────────────────────────────────────────┤
│ CAPA 3: ARTEFACTOS ENTREGABLES  │ • Dashboards HTML interactivos (Plotly.js / Vis.js)   │
│                                 │ • Tarjetas estáticas PNG/SVG incrustables en el chat │
│                                 │ • Tablas comparativas y dossiers descargables        │
└─────────────────────────────────┴──────────────────────────────────────────────────────┘
```

### Principios Rectores:
1. **Desacoplamiento Estricto:** Las skills de datos jamás deben compilar código HTML ni lidiar con librerías gráficas; generan únicamente datos tabulares y métricas normalizadas en formato JSON.
2. **Economía de Contexto:** El LLM no procesa payloads de visualización de miles de tokens; únicamente invoca una línea de comando en el terminal de su sandbox y devuelve al usuario la interpretación y el enlace al artefacto.
3. **Autocontención y Portabilidad:** Todo artefacto HTML es autocontenido (con CSS integrado y dependencias JS servidas vía CDN o locales), permitiendo visualizarse en el panel de previsualización (*Preview Panel*) de TlachIA-Hands o en cualquier navegador web moderno.
4. **Rigor Cienciométrico y Paleta Canónica:** Adopción obligatoria de la paleta oficial internacional (Acceso Abierto, ODS de la ONU y benchmark mundial en FWCI = 1.00).

---

## 2. Catálogo Exhaustivo de Artefactos Visuales

A partir de los módulos maduros desarrollados en `/home/sinapsisai` (`dashboard_analytics.py`, `report_generator.py`, `dashboard_maps.py`, `lib/viz_ods.py` y `networks/`), se formalizan los siguientes **9 artefactos prioritarios**:

---

### Artefacto 1: Dossier / Dashboard Ejecutivo HTML (`dossier-works`)
- **Objetivo:** Ofrecer una radiografía integral y filtrable de la literatura científica recuperada sobre un tema o disciplina en México.
- **Componentes Visuales:**
  - **Header con KPI Cards:** Volumen de obras listadas, citas totales acumuladas, FWCI promedio del corpus y porcentaje de publicaciones en el decil superior de impacto mundial (Top 10%).
  - **Tabla Dinámica con Desambiguación de Coautoría:** Desglose en tiempo real de autores nacionales (`mexican_affiliated_authors`) con sus instituciones (UNAM, IPN, UAM, Cinvestav) y etiquetas identificadoras de colaboradores internacionales (`international_collaborators`).
  - **Filtros por Modalidad de Acceso Abierto:** Distinción cromática entre vías Diamante, Dorada, Híbrida y Verde.
- **Tecnología:** HTML5, CSS Flexbox/Grid con tema oscuro, vanilla JavaScript para búsqueda en tabla.
- **Origen en sinapsisai:** [`report_generator.py::generate_html_report`](file:///home/sinapsisai/report_generator.py#L154).

---

### Artefacto 2: Sunburst Taxonómico Jerárquico (`sunburst`)
- **Objetivo:** Explorar la estructura de especialización disciplinaria multinivel de una institución, departamento o tópico de investigación.
- **Estructura Jerárquica:**
  $$\text{Dominio} \longrightarrow \text{Campo} \longrightarrow \text{Subcampo} \longrightarrow \text{Tópico}$$
- **Interactividad:** Clic interactivo en los círculos concéntricos para realizar *zoom in* y *zoom out* jerárquico.
- **Tecnología:** Plotly.js (`px.sunburst` / `go.Sunburst`).
- **Origen en sinapsisai:** [`dashboard_analytics.py::inst_sunburst`](file:///home/sinapsisai/dashboard_analytics.py#L1675) y [`report_generator.py::fig_sun`](file:///home/sinapsisai/report_generator.py#L688).

---

### Artefacto 3: Gráfico Donut de Modalidades de Acceso Abierto y Gasto en APC (`oa-donut`)
- **Objetivo:** Evaluar la política de publicación, soberanía editorial y fuga financiera por pago de cargos por procesamiento de artículos (APC).
- **Componentes Visuales:**
  - Donut interactivo con las 6 vías:
    - *Diamante (`#00A86B`):* Acceso abierto sin cobro para autores ni lectores.
    - *Dorada (`#E39918`):* Revistas con cobro comercial de APC.
    - *Híbrida (`#3B82F6`):* Revistas de suscripción con opción de pago por artículo.
    - *Verde (`#10B981`):* Depósito en repositorios institucionales.
    - *Bronce (`#CD7F32`):* Lectura libre sin licencia formal explícita.
    - *Cerrada (`#6B7280`):* Modelo comercial tradicional de suscripción.
  - Tarjetas de impacto financiero: Gasto estimado acumulado en APC en dólares estadounidenses (`apc_paid_usd`).
- **Tecnología:** Plotly.js (`go.Pie` con `hole=0.45`).
- **Origen en sinapsisai:** [`report_generator.py::fig_oa`](file:///home/sinapsisai/report_generator.py#L628).

---

### Artefacto 4: Serie Temporal Dual y Trayectoria de FWCI (`timeseries`)
- **Objetivo:** Monitorear la evolución interanual del volumen de producción, recepción de citas y madurez de impacto relativo normalizado.
- **Componentes Visuales:**
  - Eje Primario (Izquierdo): Barras de producción anual de documentos.
  - Eje Secundario (Derecho): Línea continua de FWCI promedio por año.
  - Línea de Referencia Crítica: Línea horizontal punteada roja fija en **FWCI = 1.00** (Media Mundial).
- **Tecnología:** Plotly.js (`make_subplots(specs=[[{"secondary_y": True}]])`).
- **Origen en sinapsisai:** [`report_generator.py::fig_hist`](file:///home/sinapsisai/report_generator.py#L314) y [`fig_fwci`](file:///home/sinapsisai/report_generator.py#L394).

---

### Artefacto 5: Ranking Horizontal de Capacidad Instalada con Desambiguación (`top-ranking`)
- **Objetivo:** Rankear a las investigadoras, investigadores o instituciones con mayor capacidad sobre una disciplina o problema nacional.
- **Componentes Visuales:**
  - Gráfica de barras horizontales donde la longitud de la barra representa el volumen de publicaciones y la escala cromática (*Viridis* o *Plasma*) codifica el FWCI promedio.
  - Etiquetas con desglose de citas e índice H.
  - Tabla complementaria con banderas explícitas de pertenencia nacional (`badge-mx`) versus colaboradores internacionales (`badge-ext`).
- **Tecnología:** Plotly.js (`go.Bar` horizontal con escala continua).
- **Origen en sinapsisai:** [`dashboard_analytics.py::render_institucion_view`](file:///home/sinapsisai/dashboard_analytics.py#L1303).

---

### Artefacto 6: Grafo Interactivo de Coautoría y Red Institucional (`network`)
- **Objetivo:** Visualizar la red de colaboración científica entre autores o instituciones sobre una línea de investigación.
- **Componentes Visuales:**
  - Nodos: Investigadores o instituciones (tamaño ponderado por volumen de producción o citas).
  - Aristas: Fuerza de colaboración medida por coautorías compartidas.
  - Algoritmo de Física: *ForceAtlas2* o *Barnes-Hut* con física de resortes interactiva (los nodos pueden ser arrastrados y fijados).
  - Detección de Comunidades: Coloreo modular por algoritmos de partición de grafos (Louvain / Leiden).
- **Tecnología:** PyVis / Vis.js (`pyvis.network.Network`).
- **Origen en sinapsisai:** [`report_generator.py`](file:///home/sinapsisai/report_generator.py#L12) y [`networks/build_network_json.py`](file:///home/sinapsisai/networks/build_network_json.py).

---

### Artefacto 7: Proyección Semántica 2D / Mapa Conceptual UMAP (`semantic-manifold`)
- **Objetivo:** Mostrar la variedad semántica y la proximidad temática de las publicaciones a partir de sus vectores de embeddings Nomic de 768 dimensiones.
- **Componentes Visuales:**
  - Diagrama de dispersión 2D UMAP interactivo.
  - Cada punto representa un artículo académico; los clusters contiguos representan escuelas de pensamiento o especialidades temáticas afines.
  - Tooltip *hover* con título, año, citas y filiación institucional.
- **Tecnología:** Plotly.js (`go.Scatter` con UMAP precalculado) o Deepscatter WebGL para escala masiva.
- **Origen en sinapsisai:** [`report_generator.py::fig_umap`](file:///home/sinapsisai/report_generator.py#L855) y [`dashboard_maps.py`](file:///home/sinapsisai/dashboard_maps.py#L54).

---

### Artefacto 8: Matriz de los 17 Objetivos de Desarrollo Sostenible (`sdg-grid`)
- **Objetivo:** Cuantificar la alineación de la producción científica con la Agenda 2030 de la ONU.
- **Componentes Visuales:**
  - Cuadrícula de 17 tarjetas con la iconografía oficial y colores estándar de las Naciones Unidas (ODS 1 Fin de la Pobreza a ODS 17 Alianzas).
  - Métrica de documentos aportados a cada ODS con barras de porcentaje relativo.
- **Tecnología:** HTML/CSS Grid responsivo con paleta cromática oficial ONU.
- **Origen en sinapsisai:** [`lib/viz_ods.py`](file:///home/sinapsisai/lib/viz_ods.py).

---

### Artefacto 9: Tarjeta Gráfica Rápida para el Chat (`chat-card-png`)
- **Objetivo:** Proporcionar una respuesta visual inmediata dentro de la propia burbuja conversacional del agente sin obligar al usuario a abrir un archivo externo.
- **Componentes Visuales:**
  - Gráfico estático de alta resolución (200 DPI) con fondo oscuro estilizado y tipografía legible.
- **Tecnología:** Matplotlib (`Agg` backend) guardado en disco y enlazado mediante Markdown (`![Gráfica](file:///ruta/tarjeta.png)`).

---

## 3. Matriz de Orquestación: Mapeo de Skills a Artefactos

El agente sigue la siguiente matriz de decisiones determinista para enlazar los datos extraídos con la visualización adecuada:

| Consulta Típica del Usuario | Skill de Datos Utilizada | Salida de Datos | Subcomando de `openalex-mexico-visualizer` | Artefacto Generado |
| :--- | :--- | :--- | :--- | :--- |
| *“¿Quiénes son las y los investigadores líderes en litio en México?”* | `openalex-mexico-aggregations` | `top_entities.json` | `--type top-ranking` | Artefacto 5 (Barras horizontales + Tabla desambiguada) + Tarjeta PNG. |
| *“¿Cómo ha evolucionado la producción científica en IA en los últimos 10 años?”* | `openalex-mexico-aggregations` | `time_series.json` | `--type timeseries` | Artefacto 4 (Serie dual publicaciones + FWCI anual). |
| *“¿Cuál es el porcentaje de acceso abierto y gasto en APC de la UNAM?”* | `openalex-mexico-aggregations` | `oa_agg.json` | `--type oa-donut` | Artefacto 3 (Donut 6 vías OA + Gasto APC USD). |
| *“Busca publicaciones sobre materiales para celdas solares”* | `openalex-mexico-semantic-search` o `works-search` | `works_search.json` | `--type dossier-works` | Artefacto 1 (Dossier interactivo con autores nacionales vs internacionales). |
| *“¿Cómo colaboran entre sí las universidades mexicanas en energía limpia?”* | `openalex-mexico-works-search` | `works_collab.json` | `--type network` | Artefacto 6 (Grafo de red interactiva PyVis). |
| *“Mapea la alineación de la producción en agua con los ODS”* | `openalex-mexico-aggregations` | `sdg_agg.json` | `--type sdg-grid` | Artefacto 8 (Matriz oficial 17 ODS). |

---

## 4. Fases de Implementación Técnica (Roadmap)

### Fase 1: Despliegue de la 7ª Skill y Artefactos Fundacionales (COMPLETADA)
- [x] Creación de la 7ª skill [`openalex-mexico-visualizer`](file:///mnt/expansion/desplegados/sos-mcp-services/.agents/skills/openalex-mexico-clickhouse/openalex-mexico-visualizer/SKILL.md) en `sos-mcp-services` y `TlachIA-Hands`.
- [x] Desarrollo del motor CLI [`openalex_visualizer_cli.py`](file:///mnt/expansion/desplegados/sos-mcp-services/.agents/skills/openalex-mexico-clickhouse/openalex-mexico-visualizer/scripts/openalex_visualizer_cli.py) con detección automática de tipo de datos.
- [x] Implementación de los 4 artefactos nucleares:
  - `top-ranking` (Barras horizontales con FWCI y badges nacionales/internacionales).
  - `timeseries` (Subplots duales con línea benchmark FWCI 1.00).
  - `oa-donut` (Donut de 6 vías con cálculo de gasto en APC).
  - `dossier-works` (Tabla interactiva con autores desambiguados).
  - Tarjetas rápidas PNG para el chat (`--png`).
- [x] Registro y compilación del catálogo en TlachIA-Hands (`node scripts/build-skills-catalog.mjs`).
- [x] Actualización de la documentación integral del ecosistema a 37 skills.

### Fase 2: Incorporación de Taxonomía Sunburst y Matriz de ODS (Siguiente Paso)
- [ ] Adaptar la lógica de [`dashboard_analytics.py::inst_sunburst`](file:///home/sinapsisai/dashboard_analytics.py#L1675) en `openalex_visualizer_cli.py` para admitir `--type sunburst` a partir de agregaciones por tópico/subcampo.
- [ ] Incorporar el renderizador de los 17 ODS de [`lib/viz_ods.py`](file:///home/sinapsisai/lib/viz_ods.py) en `openalex_visualizer_cli.py` para admitir `--type sdg-grid`.

### Fase 3: Grafos Avanzados de Coautoría y Colaboración
- [ ] Ampliar el módulo `--type network` para incluir cálculo de centralidad de intermediación (*betweenness*) y partición modular Louvain.
- [ ] Incorporar un buscador de nodos y filtros por número mínimo de coautorías dentro del HTML generado.

### Fase 4: Proyecciones Semánticas UMAP 2D
- [ ] Implementar `--type semantic-manifold` para proyectar en 2D con UMAP los vectores de 768 dimensiones devueltos por `openalex-mexico-semantic-search`, integrando tooltips interactivos con métricas de citas e institución.

---

## 5. Instrucciones de Uso para el Agente (Protocolo TlachIA-Hands)

Para que el modelo local de 20B en TlachIA-Hands ejecute el flujo de principio a fin, debe seguir esta secuencia canónica:

```bash
# 1. Obtención de datos (sin saturar contexto)
/home/ambientesPy/revistaslatam/bin/python \
  .agents/skills/openalex-mexico-aggregations/scripts/openalex_mexico_cli.py \
  top-entities --query "litio" --by authors --limit 10 \
  --output workspace/data/top_autores_litio.json

# 2. Renderizado del artefacto interactivo y la tarjeta para el chat
/home/ambientesPy/revistaslatam/bin/python \
  .agents/skills/openalex-mexico-visualizer/scripts/openalex_visualizer_cli.py \
  --input workspace/data/top_autores_litio.json \
  --title "Investigadores Líderes en Litio en México" \
  --output workspace/reports/top_autores_litio.html \
  --png workspace/reports/top_autores_litio.png
```

El agente responderá al usuario en el chat:
> *"He analizado a los investigadores con mayor producción e impacto en litio en México. Aquí tienes la tarjeta de resumen:*
> 
> *`![Resumen](/workspace/reports/top_autores_litio.png)`*
> 
> *Puedes explorar el diagnóstico interactivo completo con indicadores de FWCI y adscripción institucional en el siguiente enlace:*  
> *[Abrir Dashboard Interactivo](file:///workspace/reports/top_autores_litio.html)"*
