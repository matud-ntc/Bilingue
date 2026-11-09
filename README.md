# Bilingüe

Addon para **World of Warcraft: Forever**. Dejás el mouse quieto un momento sobre algo y abajo aparece cómo se llama en el otro idioma: si jugás en inglés te muestra el nombre en español (esMX), y si jugás en español te muestra el inglés.

## Dónde aparece

| Dónde | Qué traduce |
|---|---|
| Tooltips | items (bolsas, vendor, loot, AH, links del chat), hechizos, talentos, buffs, NPCs y su título (`<Weaponsmith>`), hierbas, vetas, cofres, misiones linkeadas |
| Mapa del mundo | la zona, subzona o mazmorra que tenés debajo del cursor |
| Minimapa | zona y subzona al pasar por el nombre |
| Log de misiones | título de la misión y nombre de la zona en los encabezados |
| `/bil <texto>` | busca en los dos idiomas, con o sin tildes: `/bil trueno furioso`, `/bil peacebloom` |

`/bil delay 1.5` cambia la demora (0 = al instante) · `/bil off` / `/bil on`. También responde a `/trad`.

## Instalación

Copiar (o symlinkear) `Bilingue/` en `World of Warcraft/_forever_/Interface/AddOns/` y reiniciar el juego.

## Datos

`scripts/build_data.py` genera `Data_enUS.lua` (lo carga un cliente en inglés) y `Data_es.lua` (esMX/esES). Cada cliente solo arma en memoria el suyo.

| Fuente | Qué aporta |
|---|---|
| [wago.tools](https://wago.tools) DB2 de la build de Forever, enUS y esMX | items, hechizos/talentos, zonas, mapas, facciones, profesiones, clases, razas |
| QuestieDB instalado (datos de Forever + `l10n/Forever`) | NPCs y títulos, misiones, objetos |

Al cambiar de parche:

```
python3 scripts/build_data.py --build <versión de wowf>
```

La versión está en `World of Warcraft/.build.info` (línea `wowf`). Los CSV quedan cacheados en `.cache/`. Necesita `lua5.4` para leer QuestieDB.

Nombres que son iguales en los dos idiomas (Durotar, Orgrimmar, Thrall) no muestran nada.

## Licencia

GPL-3.0 (los nombres de NPCs, misiones y objetos vienen de QuestieDB, GPL-3.0).
