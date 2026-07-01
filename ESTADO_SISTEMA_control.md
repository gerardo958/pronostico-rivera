# Documento de control — Sistema PronosticoRivera + AlertaRivera
### Fuente de verdad del estado del sistema. Guardado por el usuario, no por la memoria de Claude.
### Este documento se apoya en verificaciones sobre el código y el repositorio real, no en reconstrucciones de memoria.

Última actualización verificada: 2026-07-01 (sistema de pronóstico funcionando de punta a punta; token y GDD resueltos y publicados)

---

## ENTORNO
- Python de QGIS 4.0.2: `"C:\Program Files\QGIS 4.0.2\apps\Python312\python.exe"`
- Windows, usuario `G A`.
- **Regla de carpetas (acordada):** todo lo que corre vive en AppData
  `C:\Users\G A\AppData\Roaming\PronosticoRivera`. Se ejecuta parado ahí.
  Scripts_Rivera (`C:\Users\G A\Desktop\Scripts_Rivera`) = solo respaldo.
  AlertaRivera (`C:\Users\G A\Desktop\AlertaRivera`) = sistema aparte.
- Repo del sitio: `C:\Users\G A\Desktop\pronostico-rivera` → GitHub Pages
  https://gerardo958.github.io/pronostico-rivera/

---

## GDD (grados-día) — RESUELTO Y PUBLICADO ✓
Método horario = suma de los excesos horarios sobre el umbral base, **DIVIDIDA ENTRE 24**.
Cada hora aporta `max(0, T - Tbase)`; se suman las 24 y se divide entre 24.

Función `gdd_horario_dia` en `calcular_indices.py` termina en `return total / 24.0`.

Verificación de referencia: día con temperaturas
`[8,7,7,6,6,7,9,11,13,15,17,19,21,22,22,21,19,17,15,13,12,11,10,9]`, Tbase 10
→ suma de excesos = 98 → **98/24 = 4.08 grados-día**.

VERIFICADO EN LA WEB PUBLICADA (2026-07-01): el gráfico de Estación Ataques muestra
Sandía 3.6 GDD para la semana (escala correcta). Antes daba 117 (mal, sin dividir).

Umbrales: maíz Tbase 10, trigo Tbase 0, sandía Tbase 10.

---

## PESTAÑAS DE LA WEB — HECHO Y PUBLICADO (verificado en el repo)
Eliminadas de las listas `GRUPOS["claves"]` en `deploy_pronostico.py`:
- Agricultura: se quitaron **eólica, solar, incendio forestal (FWI)**.
- Ganadería: se quitó **confort humano (UTCI)**.

Estado REAL del repo publicado (verificado 2026-07-01):
- `agricultura.html` enlaza solo: agroquimicos, apicultura, gdd, helada, horas_frio, melcast_efi.
- `ganaderia.html` enlaza solo: annoni_ids, annoni_irga, annoni_ivga, bano_biologico,
  empaste, garrapata, ith_lechero, pietin.
- Las pestañas eliminadas NO aparecen. Si se ven en el navegador = caché local, no el sitio.
- (Existen páginas huérfanas idx_fwi/idx_eolica/idx_solar/idx_utci que no enlaza nadie.
  No se ven. Si se quiere, se pueden borrar del repo; no es urgente.)

---

## TOKEN DE GITHUB — RESUELTO ✓ (con una decisión de diseño)
Estado final: el token va DIRECTO en la línea `GITHUB_TOKEN = "ghp_..."` del deploy.
El deploy vive en AppData (`C:\Users\G A\AppData\Roaming\PronosticoRivera`), FUERA de
la carpeta del repo, por eso el token NO entra al repositorio ni lo sube git.
El deploy tiene `credential.helper=` desactivado y push forzado con `--allow-empty`.

VERIFICADO (2026-07-01): el deploy corrió solo y publicó
`[OK] Publicado en https://gerardo958.github.io/pronostico-rivera/`, sin pedir
credenciales, sin token en el repo. El ciclo automático funciona.

Historia (por si reaparece): hubo un intento de leer el token de un archivo
`token_github.txt`, que terminó metiendo el token en el historial git y bloqueando
el push (secret-scanning). Se resolvió: (a) rehaciendo el commit local limpio,
(b) `git push -f origin main` para reemplazar el remoto, (c) volviendo al token
directo en el deploy. Ese enfoque del archivo NO se usa más.

PENDIENTE DE SEGURIDAD: rotar el token. Uno quedó expuesto en un chat; revocarlo en
GitHub (Settings → Developer settings → Personal access tokens) y poner uno nuevo en
la línea GITHUB_TOKEN del deploy. El sistema funciona igual mientras tanto.

---

## AlertaRivera — SISTEMA NUEVO, APARTE — EN CONSTRUCCIÓN
Objetivo: llevar a la web el "Sistema de Alerta Agrícola sobre las Condiciones Hídricas
en Rivera" (informe mensual, último jueves del mes). SEPARADO del pronóstico diario.

Diseño: **semiautomático controlado por técnicos**. El semáforo de 5 colores y los textos
los decide el técnico, NUNCA el script. Tres capas:
1. Automática — datos estacionales de Open-Meteo Seasonal (SEAS5, mismo modelo que C3S).
2. Manual — planilla donde el técnico pega lo no automatizable (GRACE FO, Sentinel,
   CHIRPS, INIA-GRAS, NOAA/OMM/INUMET) y define semáforo y textos.
3. Publicación — página web mensual: portada, resumen, 3 plazos (corto ≤15d, mediano
   ≤90d, largo ≤180d).

HECHO Y FUNCIONANDO: `alerta_seasonal.py` (en Desktop\AlertaRivera).
- Consulta `seasonal-api.open-meteo.com/v1/seasonal`, modelo `ecmwf_seas5`,
  variables `daily` (precipitation_sum, temperature_2m_mean), 6 puntos del departamento.
- Agrega a mensual (precip sumada, temp promediada), promedia área, genera JSON/CSV/PNG.
- Probado con datos reales: jul ~95mm/13.5°C … dic ~128mm/22.4°C (valores absolutos).

PENDIENTE en AlertaRivera:
1. Calcular ANOMALÍAS (desviación respecto a lo normal) y validarlas contra los datos
   C3S que ya cita el informe de junio (+30mm oct, +20-30 nov, +45-55 dic).
2. Capa de publicación web (HTML con semáforo de 5 colores y los 3 plazos), integrable
   como sección del sitio existente (panel "Indicadores Hídricos" de la portada).
3. Definir la planilla de la capa manual.

---

## CÓMO CORRER EL PRONÓSTICO DIARIO (verificado 2026-07-01)
Todo desde AppData:
```
cd "C:\Users\G A\AppData\Roaming\PronosticoRivera"
"C:\Program Files\QGIS 4.0.2\apps\Python312\python.exe" calcular_indices.py
"C:\Program Files\QGIS 4.0.2\apps\Python312\python.exe" deploy_pronostico.py
```
El deploy termina en `[OK] Publicado en https://gerardo958.github.io/pronostico-rivera/`.
Nota: un .py NO se ejecuta solo escribiendo su ruta; hay que llamar a python.exe y
pasarle el script, con comillas por los espacios en las rutas.

## CÓMO USAR ESTE DOCUMENTO
Al abrir un chat nuevo, pegar este documento. Es el estado real del sistema.
Claude NO tiene memoria fiel entre chats: lee una síntesis con pérdida que puede
arrastrar errores. Este archivo, mantenido por el usuario, es la fuente de verdad.
Cuando algo cambie, actualizar este archivo — no confiar en que Claude lo recuerde.
