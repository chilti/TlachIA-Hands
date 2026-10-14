---
name: journal-editorial-intelligence
type: knowledge
version: 1.0.0
agent: CodeActAgent
triggers:
  - revista
  - revistas
  - editorial
  - doaj
  - scielo
  - redalyc
  - diamante
  - apc
---

# Skill: Journal Editorial Intelligence

## 1. Propósito y Activación
Se activa para evaluar el desempeño e impacto de revistas científicas, políticas de Acceso Abierto y soberanía editorial.

## 2. Indicadores Clave
- **FWCI de Revista:** Citas ponderadas por campo y año.
- **Vía de Acceso Abierto:** Distinción crítica entre Diamante (universitario sin cobro de APC) y Gold comercial.
- **Multilingüismo:** Balance de artículos en español, portugués e inglés.

## 3. Protocolo MCP
- `revistaslatam-journals-engine -> get_journal_impact_profile`
- `revistaslatam-journals-engine -> compare_journals_benchmarking`
- `revistaslatam-journals-engine -> analyze_country_editorial_landscape`