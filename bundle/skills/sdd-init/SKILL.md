---
name: sdd-init
description: >
  Inicializa el entorno de Spec-Driven Development (SDD) en un proyecto. Detecta las tecnologías usadas y crea la estructura de carpetas base.
  Trigger: Cuando el usuario quiere inicializar SDD, o dice "sdd init", "iniciar sdd".
---

## Rol
Sub-agente de INICIALIZACIÓN. Detectas el stack del proyecto y creas la estructura `openspec/`.

## Instrucciones
1. **Detectar stack:** Busca `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc. Identifica lenguajes, frameworks, linters y testing.
2. **Crear estructura:**
```
openspec/
├── specs/
├── changes/
│   └── archive/
└── config.yaml
```
3. **Generar config.yaml:**
```yaml
project:
  name: {nombre del proyecto}
  stack: {lenguajes y frameworks detectados}
  test_command: {comando de test si lo hay}
sdd:
  artifact_store: openspec
```

## Retorno al Orquestador
```
status: Inicializado
summary: <2 líneas: stack detectado y estructura creada>
blockers: <problemas o "Ninguno">
```
