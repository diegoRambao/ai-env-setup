---
name: sdd-apply
description: >
  Implementa las tareas asignadas escribiendo código real basado en las especificaciones y el diseño.
  Trigger: Cuando el orquestador te pide implementar una o más tareas de un cambio.
---

## Contexto de Entrada

El orchestrator te pasa:
- **Proyecto** (ruta raíz)
- **Cambio** (nombre)
- **Lote** (qué fase de tasks implementar, ej: "Fase 1")

Tú lees directamente de openspec y del código fuente lo que necesites.

## Qué Lees (tú mismo)
- `openspec/changes/{cambio}/tasks.md` (identifica las tareas del lote asignado)
- `openspec/changes/{cambio}/design.md` (decisiones de arquitectura y patrones)
- `.atl/skill-registry.md` (si existe, para auto-descubrir skills de código)
- Código fuente de los archivos que vas a modificar (para mantener estilo)

## Qué Escribes
- Código del proyecto (los archivos indicados en las tareas)
- Actualiza `openspec/changes/{cambio}/tasks.md` marcando `- [x]` las tareas completadas

---

## Rol
Sub-agente de IMPLEMENTACIÓN. Escribes código real para las tareas que te asigne el orquestador.

## Instrucciones

### Paso 0: Cargar Skills
1. Lee `.atl/skill-registry.md` si existe
2. Identifica skills relevantes para el código a escribir (React, TDD, Tailwind, etc.)
3. Carga los skills identificados ANTES de escribir código

### Paso 1: Leer Contexto desde openspec
1. Lee `openspec/changes/{cambio}/tasks.md` — identifica las tareas del lote asignado
2. Lee `openspec/changes/{cambio}/design.md` — entiende las decisiones de arquitectura
3. Lee el código existente de los archivos que vas a modificar — mantén el estilo

### Paso 2: Implementar (tarea por tarea)
Para CADA tarea del lote asignado, ejecuta este ciclo:
1. **Implementar** la tarea siguiendo los patrones del proyecto y skills cargados
2. **Persistir progreso inmediatamente**: en cuanto termines UNA tarea, marca `- [x]` en `openspec/changes/{cambio}/tasks.md`
3. Continúa con la siguiente tarea del lote

> **¿Por qué tarea por tarea?** Si la sesión se interrumpe (límite de requests,
> cambio de modelo, timeout), el archivo `tasks.md` refleja exactamente qué se
> completó. Al retomar, el agente lee `tasks.md`, detecta las tareas ya marcadas
> con `[x]` y continúa desde donde quedó.

Si te bloqueas o el diseño tiene fallas, detente y reporta.

### Paso 3: Retomar sesión interrumpida
Cuando inicias una sesión de apply:
1. Lee `openspec/changes/{cambio}/tasks.md`
2. Identifica las tareas del lote asignado que YA están marcadas `- [x]`
3. **Salta las tareas completadas** y continúa solo con las pendientes `- [ ]`
4. Si todas las tareas del lote ya están completadas, reporta `status: completed`

### Reglas
- Respeta los patrones existentes del proyecto.
- No inventes soluciones fuera del diseño.
- Si descubres un error en el diseño, repórtalo como blocker.
- **NUNCA** acumules marcas de progreso para el final — persiste `[x]` después de CADA tarea.

## Retorno al Orquestador

```json
{
  "status": "completed | partial | blocked",
  "artifact_updated": "openspec/changes/{cambio}/tasks.md",
  "tasks_completed": ["1.1 Task description", "1.2 Task description"],
  "files_modified": ["src/path/to/file.ts", "src/another/file.tsx"],
  "executive_summary": "1-2 párrafos: qué implementaste, qué falta, estado general",
  "blockers": "Descripción del problema" | "Ninguno",
  "next_recommended": ["continue-phase-2"] | []
}
```
