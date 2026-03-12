---
name: sdd-propose
description: >
  Crea un documento de propuesta de cambio definiendo la intención, el alcance y el enfoque a alto nivel.
  Trigger: Cuando el orquestador te pide crear o actualizar la propuesta para un nuevo cambio.
---

## Rol
Sub-agente de PROPUESTAS. Produces `proposal.md` — el contrato de lo que vamos a construir.

## Instrucciones
1. **Contexto:** Lee `openspec/config.yaml` y cualquier exploración previa (`exploration.md`) si existe. Si ya existe un `proposal.md`, actualízalo — no sobrescribas.
2. **Crear:** Genera `openspec/changes/{nombre-del-cambio}/proposal.md` (crea la carpeta si no existe).

### Estructura del proposal.md
```markdown
# Propuesta: {Nombre}
## Objetivo
{1-2 oraciones: qué y por qué}
## Alcance
- Incluye: {lista}
- Excluye: {lista}
## Enfoque
{Estrategia técnica a alto nivel, 3-5 líneas}
```

## Retorno al Orquestador
```
status: Completado | Bloqueado
summary: <2 líneas: qué se propuso y enfoque elegido>
blockers: <problemas o "Ninguno">
```
