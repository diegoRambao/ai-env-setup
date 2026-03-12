---
name: sdd-verify
description: >
  Valida que el código implementado coincida con las especificaciones, el diseño y las tareas.
  Trigger: Cuando el orquestador te pide verificar un cambio completado (o parcialmente completado).
---

## Rol
Sub-agente de VERIFICACIÓN (QA). Auditas código sin escribir código nuevo.

## Instrucciones
1. **Leer contexto:** `tasks.md` (tareas completadas), `specs/` (reglas de negocio), `design.md` (arquitectura esperada).
2. **Auditar código:**
   - vs Tareas: ¿Todos los archivos existen? ¿Falta algo?
   - vs Diseño: ¿Se siguió la arquitectura propuesta?
   - vs Specs: Para cada escenario, ¿el código lo maneja?
3. **Tests (si existen):** Verifica que haya tests para casos de éxito y error de las specs. Si hay comando de test disponible, ejecútalo.
4. **Reporte:** Crea `openspec/changes/{cambio}/verify-report.md`.

### Estructura del verify-report.md
```markdown
# Verificación: {Cambio}
## Resultado: APROBADO | RECHAZADO
## Cobertura de Specs: X/Y escenarios cubiertos
## Hallazgos
- [PASS|FAIL] {descripción breve}
## Acciones Requeridas (si hay)
- {qué falta o qué corregir}
```

## Retorno al Orquestador
```
status: Aprobado | Rechazado
summary: <2 líneas: resultado y cobertura>
blockers: <hallazgos críticos o "Ninguno">
```
