---
name: geopolitical-science-mapping
type: knowledge
version: 1.0.0
agent: CodeActAgent
triggers:
  - geopolitica
  - coautoria internacional
  - acceso abierto
  - ods
  - cooperacion
  - paises
---

# Skill: Geopolitical Science Mapping

## 1. Propósito y Activación
Se activa para analizar la geopolítica de la producción científica, impacto de colaboraciones Norte-Sur / Sur-Sur y compromisos con la Agenda 2030 ONU.

## 2. Protocolo MCP
1. `topics-research-fronts-engine -> get_geopolitical_collaboration_matrix`: Identificar socios estratégicos (EE.UU., España, Francia, Brasil).
2. `topics-research-fronts-engine -> get_open_access_transition_data`: Evaluar transición a Acceso Abierto.
3. `topics-research-fronts-engine -> get_sdg_impact_matrix`: Cuantificar alineación con los 17 ODS.