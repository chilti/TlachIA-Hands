#!/usr/bin/env node
/**
 * scripts/build-skills-catalog.mjs
 * 
 * Scans SKILL.md files from .agents/skills/ and generates a typed TypeScript
 * catalog in src/catalog/tlachia-skills.ts.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

const candidateDirs = [
  path.resolve(rootDir, '.agents/skills'),
  path.resolve('/mnt/expansion/desplegados/sos-mcp-services/.agents/skills'),
  path.resolve(rootDir, '../sos-mcp-services/.agents/skills'),
];

let skillsDir = null;
for (const dir of candidateDirs) {
  if (fs.existsSync(dir) && fs.statSync(dir).isDirectory()) {
    skillsDir = dir;
    break;
  }
}

if (!skillsDir) {
  const existingPath = path.resolve(rootDir, 'src/catalog/tlachia-skills.ts');
  if (fs.existsSync(existingPath) && fs.statSync(existingPath).size > 100) {
    console.log(`[build-skills-catalog] Using existing pre-generated catalog: ${existingPath}`);
    process.exit(0);
  }
  console.error('[build-skills-catalog] ERROR: Could not locate skills directory.');
  process.exit(1);
}

console.log(`[build-skills-catalog] Reading skills from: ${skillsDir}`);

const skillFolders = fs.readdirSync(skillsDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory())
  .map(dirent => dirent.name);

const catalogEntries = [];

for (const folderName of skillFolders) {
  const skillFile = path.join(skillsDir, folderName, 'SKILL.md');
  if (!fs.existsSync(skillFile)) {
    continue;
  }

  const fileContent = fs.readFileSync(skillFile, 'utf8');
  let name = folderName;
  let description = '';
  let content = fileContent;
  let category = 'scientometrics';
  let triggers = [`/${folderName}`];

  // Parse YAML frontmatter
  if (fileContent.startsWith('---')) {
    const endIdx = fileContent.indexOf('\n---', 3);
    if (endIdx !== -1) {
      const frontmatter = fileContent.slice(3, endIdx).trim();
      content = fileContent.slice(endIdx + 4).trim();
      
      const lines = frontmatter.split('\n');
      for (const line of lines) {
        const colonIdx = line.indexOf(':');
        if (colonIdx !== -1) {
          const key = line.slice(0, colonIdx).trim();
          const val = line.slice(colonIdx + 1).trim().replace(/^['"]|['"]$/g, '');
          if (key === 'name') name = val;
          if (key === 'description') description = val;
          if (key === 'category') category = val;
        }
      }
    }
  }

  // --- Keyword triggers por skill (español + inglés) ---
  const SKILL_TRIGGERS = {
    'bibliometric-network-analyst': [
      '/bibliometric-network-analyst',
      'red de coautoría', 'red bibliométrica', 'coautoría', 'co-citación',
      'acoplamiento bibliográfico', 'bibliographic coupling', 'louvain',
      'bibliometric network', 'coauthorship network',
    ],
    'classical-bibliometrics-laws': [
      '/classical-bibliometrics-laws',
      'ley de lotka', 'ley de bradford', 'ley de zipf', 'índice de price',
      'lotka law', 'bradford law', 'bibliometric laws', 'leyes bibliométricas',
      'productividad de autores',
    ],
    'geopolitical-science-mapping': [
      '/geopolitical-science-mapping',
      'cartografía científica', 'mapa geopolítico', 'colaboración internacional',
      'acceso abierto', 'open access', 'ods', 'sdg',
      'geopolitical science', 'science mapping',
    ],
    'graphrag-scientific-intelligence': [
      '/graphrag-scientific-intelligence',
      'graphrag', 'grafo de conocimiento', 'knowledge graph', 'snii',
      'perfil de investigador', 'researcher profile', 'neo4j', 'qdrant',
      'búsqueda semántica', 'semantic search',
    ],
    'infotlachia-scholar-intelligence': [
      '/infotlachia-scholar-intelligence',
      'infotlachia', 'analytics cache', 'padrón snii', 'snii 2025',
      'apc estimado', 'gini temático', 'umap', 'parquet analítico',
    ],
    'journal-editorial-intelligence': [
      '/journal-editorial-intelligence',
      'evaluación de revista', 'journal evaluation', 'revistas científicas',
      'acceso abierto diamante', 'diamond open access', 'doaj', 'scielo',
      'latindex', 'redalyc', 'indexación editorial',
    ],
    'knomap-unified-orchestrator': [
      '/knomap-unified-orchestrator',
      'knomap', 'análisis bibliométrico', 'estudio bibliométrico',
      'bibliometric analysis', 'bibliometric study', 'bibliometría',
      'análisis de publicaciones', 'análisis de producción científica',
      'producción científica', 'estudio cienciométrico', 'cienciometría',
      'facultad de ciencias', 'unam', 'institución', 'universidad',
    ],
    'openalex-search-engineer': [
      '/openalex-search-engineer',
      'openalex', 'buscar artículos', 'buscar trabajos', 'search papers',
      'clickhouse', 'consulta bibliográfica', 'open alex',
    ],
    'research-fronts-detection-expert': [
      '/research-fronts-detection-expert',
      'frentes de investigación', 'research fronts', 'detección temática',
      'linajes temáticos', 'ami', 'evolución longitudinal',
    ],
    'revistaslatam-editorial-intelligence': [
      '/revistaslatam-editorial-intelligence',
      'revistas latam', 'revistas iberoamericanas', 'catálogo de revistas',
      'editorial iberoamericana', 'revistaslatam',
    ],
    'scientometrics-incites-expert': [
      '/scientometrics-incites-expert',
      'incites', 'clarivate', 'benchmarking institucional', 'indicadores bibliométricos',
      'wos', 'web of science', 'impact factor', 'factor de impacto',
      'h-index', 'índice h',
    ],
    'semantic-manifold-expert': [
      '/semantic-manifold-expert',
      'dimensión intrínseca', 'variedad semántica', 'semantic manifold',
      'mle', 'compresión topológica', 'umap',
    ],
    'som-methodological-expert': [
      '/som-methodological-expert',
      'som', 'kohonen', 'mapa auto-organizado', 'self-organizing map',
      'u-matrix', 'cluster som', 'topología neuronal',
    ],
    'topics-research-fronts-intelligence': [
      '/topics-research-fronts-intelligence',
      'topics & research fronts', 'linajes aluviales', 'sunburst',
      'cuadrantes geopolíticos', 'frentes por país',
    ],
    'tlachia-master-index': [],
  };

  triggers = SKILL_TRIGGERS[folderName] ?? [`/${folderName}`];

  catalogEntries.push({
    name,
    description,
    category,
    triggers,
    content,
    license: 'UNAM LDNL',
    compatibility: 'TlachIA-Hands / Antigravity',
  });
}

catalogEntries.sort((a, b) => a.name.localeCompare(b.name));

const outputDir = path.resolve(rootDir, 'src/catalog');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const outputPath = path.join(outputDir, 'tlachia-skills.ts');

const tsContent = `/**
 * AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
 * Generated by scripts/build-skills-catalog.mjs
 * Contains the 14 UNAM Scientometrics & Bibliometrics Skills for TlachIA-Hands
 */
import type { SkillCatalogEntry } from "@openhands/extensions/skills";

export const TLACHIA_SKILLS_CATALOG: SkillCatalogEntry[] = ${JSON.stringify(catalogEntries, null, 2)};

export const TLACHIA_SKILL_NAMES: readonly string[] = TLACHIA_SKILLS_CATALOG.map(
  (skill) => skill.name,
);
`;

fs.writeFileSync(outputPath, tsContent, 'utf8');
console.log(`[build-skills-catalog] Successfully generated ${catalogEntries.length} skills in ${outputPath}`);
