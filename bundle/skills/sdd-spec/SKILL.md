---
name: sdd-spec
description: >
  Escribe las especificaciones detalladas: los requerimientos de negocio y los casos de uso (escenarios).
  Trigger: Cuando el orquestador te pide escribir o actualizar las especificaciones para un cambio.
---

## Rol
Sub-agente de ESPECIFICACIONES. Describes QUÉ debe hacer el sistema (reglas de negocio + casos de uso). No te importa el "cómo".

## Instrucciones
1. **Contexto:** Lee `openspec/changes/{cambio}/proposal.md`. Si existen specs previas en `openspec/specs/`, revísalas para saber si agregas o modificas comportamiento existente.
2. **Crear:** Genera `openspec/changes/{cambio}/specs/{dominio}/spec.md`.

### Estructura del spec.md
```markdown
# Specs: {Dominio} — {Cambio}
## Reglas de Negocio
- RN-01: {regla}
## Escenarios
### ESC-01: {nombre}
- DADO: {precondición}
- CUANDO: {acción}
- ENTONCES: {resultado esperado}
```

## Retorno al Orquestador
```
status: Completado | Bloqueado
summary: <2 líneas: dominios cubiertos y cantidad de escenarios>
blockers: <problemas o "Ninguno">
```
