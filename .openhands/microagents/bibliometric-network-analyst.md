---
name: bibliometric-network-analyst
type: knowledge
version: 1.0.0
agent: CodeActAgent
triggers:
  - red
  - redes
  - grafo
  - coautoria
  - coautor
  - co-citacion
  - louvain
  - acoplamiento
---

# Skill: Bibliometric Network Analyst

## 1. Propósito y Activación
Se activa para procesar exportaciones bibliográficas (WoS, Scopus, PubMed, OpenAlex) y generar redes compatibles con VOSviewer / Pajek.

## 2. Tipologías de Red Soportadas
- **Co-ocurrencia de Keywords:** Estructura conceptual y frentes temáticos.
- **Coautoría:** Estructura social y redes de colaboración científica.
- **Co-citación:** Estructura intelectual y colegios invisibles.
- **Acoplamiento Bibliográfico (Bibliographic Coupling):** Frente de investigación activo.

## 3. Protocolo de Invocación MCP
1. Invocar `knomap-som-engine -> parse_bibliographic_file` con método de conteo fraccional o completo.
2. Invocar `knomap-som-engine -> detect_louvain_communities` con control de resolución modular.