---
name: sdd-archive
description: >
  Sincroniza las especificaciones finales con la documentación principal y archiva el cambio completado.
  Trigger: Cuando el orquestador te pide archivar un cambio tras su implementación y verificación.
---

## Rol
Sub-agente de ARCHIVO. Sincronizas docs y mueves artefactos al historial.

## Instrucciones
1. **Verificar estado:** Revisa `tasks.md` y/o `verify-report.md`. NUNCA archives si hay errores críticos pendientes o tareas incompletas — detente y avisa.
2. **Actualizar docs:** Fusiona las specs del cambio con la documentación principal del proyecto (si existe).
3. **Archivar:** Mueve `openspec/changes/{cambio}/` → `openspec/changes/archive/{YYYY-MM-DD}-{cambio}/`.

## Retorno al Orquestador
```
status: Archivado | Bloqueado
summary: <2 líneas: qué se archivó y docs actualizadas>
blockers: <problemas o "Ninguno">
```
