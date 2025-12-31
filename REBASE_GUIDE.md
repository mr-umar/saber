# Guía para Actualizar el Fork (Sincronizar con Upstream)

Esta guía explica cómo mantener tus cambios locales actualizados con las novedades del repositorio original utilizando `git rebase`. Esta es la mejor forma de mantener un historial limpio y lineal.

## 1. Configuración Inicial (Solo la primera vez)

Si aún no has añadido el repositorio original como "upstream", hazlo con este comando:

```bash
git remote add upstream https://github.com/saber-notes/saber
```

## 2. Proceso de Actualización

Sigue estos pasos regularmente para traer los cambios nuevos:

### Paso A: Obtener cambios de upstream
```bash
git fetch upstream
```

### Paso B: Rebasar tus cambios
Asegúrate de estar en tu rama principal (`main`) y ejecuta:
```bash
git checkout main
git rebase upstream/main
```

> **¿Qué hace esto?** 
> Git "despega" temporalmente tus commits, pone los nuevos de Saber Notes, y luego vuelve a pegar tus commits encima uno por uno.

### Paso C: Resolver conflictos (Si aparecen)
Si git se detiene por un conflicto:
1. Abre los archivos marcados y elige el código que quieres mantener.
2. Guarda el archivo y márcalo como resuelto: `git add <archivo>`.
3. Continua el proceso: `git rebase --continue`.

### Paso D: Actualizar tu GitHub (origin)
Como has reescrito el historial localmente, debes forzar la subida a tu fork remoto:

```bash
git push origin main --force
```

---

## Diferencia entre Rebase y Merge

- **Merge**: Crea un "commit de mezcla" que une las dos ramas. El historial se vuelve difícil de leer con el tiempo.
- **Rebase**: Mantiene tus cambios siempre en la "cima" del historial, como si siempre hubieras programado sobre la versión más reciente del original. ¡Es más limpio!
